import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();

  // RevenueCat API Keys - Replace these with your actual keys from RevenueCat dashboard
  // Get your keys at: https://app.revenuecat.com/
  static const String _googleApiKey = 'YOUR_REVENUECAT_GOOGLE_API_KEY';
  static const String _appleApiKey = 'YOUR_REVENUECAT_APPLE_API_KEY';

  // Entitlement ID - This is configured in RevenueCat dashboard
  // Create an entitlement called "premium" that includes your product
  static const String entitlementId = 'premium';

  factory PremiumService() => _instance;
  PremiumService._internal();

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  bool _purchasePending = false;
  bool get purchasePending => _purchasePending;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Get the current product package (for displaying price)
  Package? get currentPackage {
    return _offerings?.current?.lifetime ??
           _offerings?.current?.availablePackages.firstOrNull;
  }

  /// Get the price string to display
  String get priceString {
    return currentPackage?.storeProduct.priceString ?? 'Loading...';
  }

  Future<void> initialize() async {
    try {
      // Configure RevenueCat
      late PurchasesConfiguration configuration;

      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else {
        // Unsupported platform
        debugPrint('RevenueCat: Unsupported platform');
        _isInitialized = true;
        notifyListeners();
        return;
      }

      await Purchases.configure(configuration);

      // Enable debug logs in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Check current customer info for premium status
      await _updatePremiumStatus();

      // Load available offerings (products)
      await _loadOfferings();

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
      _errorMessage = 'Failed to initialize purchases. Please restart the app.';
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load offerings: $e');
    }
  }

  Future<void> _updatePremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPremium = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _isPremium = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    _purchasePending = false;
    notifyListeners();
  }

  Future<bool> purchasePremium() async {
    _errorMessage = null;

    if (!_isInitialized) {
      _errorMessage = 'Purchase system not ready. Please try again.';
      notifyListeners();
      return false;
    }

    final package = currentPackage;
    if (package == null) {
      _errorMessage = 'Product not available. Please try again later.';
      notifyListeners();
      return false;
    }

    try {
      _purchasePending = true;
      notifyListeners();

      final customerInfo = await Purchases.purchasePackage(package);

      _isPremium = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      _purchasePending = false;
      notifyListeners();

      return _isPremium;
    } on PurchasesErrorCode catch (e) {
      _purchasePending = false;

      switch (e) {
        case PurchasesErrorCode.purchaseCancelledError:
          _errorMessage = 'Purchase was canceled';
          break;
        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          _errorMessage = 'Product not available for purchase';
          break;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          _errorMessage = 'You already own this product. Try restoring purchases.';
          break;
        case PurchasesErrorCode.networkError:
          _errorMessage = 'Network error. Please check your connection.';
          break;
        case PurchasesErrorCode.paymentPendingError:
          _errorMessage = 'Payment is pending. Please wait.';
          break;
        default:
          _errorMessage = 'Purchase failed. Please try again.';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _purchasePending = false;
      debugPrint('Purchase error: $e');

      // Handle specific RevenueCat errors
      if (e is PlatformException) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          _errorMessage = 'Purchase was canceled';
        } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
          _errorMessage = 'You already own this product. Try restoring purchases.';
        } else {
          _errorMessage = 'Purchase failed: ${e.message}';
        }
      } else {
        _errorMessage = 'Purchase failed. Please try again.';
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    _errorMessage = null;

    if (!_isInitialized) {
      _errorMessage = 'Purchase system not ready. Please try again.';
      notifyListeners();
      return false;
    }

    try {
      _purchasePending = true;
      notifyListeners();

      final customerInfo = await Purchases.restorePurchases();

      _isPremium = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      _purchasePending = false;
      notifyListeners();

      return _isPremium;
    } catch (e) {
      _purchasePending = false;
      debugPrint('Restore error: $e');
      _errorMessage = 'Failed to restore purchases. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.dispose();
  }
}
