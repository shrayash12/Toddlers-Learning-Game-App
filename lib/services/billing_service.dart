import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService extends ChangeNotifier {
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();

  // Product ID - Must match what you create in Google Play Console
  static const String premiumProductId = 'premium_bundle';
  static const String premiumPriceDisplay = '₹299';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _purchasePending = false;
  bool get purchasePending => _purchasePending;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  ProductDetails? get premiumProduct {
    try {
      return _products.firstWhere((p) => p.id == premiumProductId);
    } catch (e) {
      return null;
    }
  }

  String get displayPrice => premiumProduct?.price ?? premiumPriceDisplay;

  // Callbacks
  Function()? onPurchaseSuccess;
  Function(String errorMessage)? onPurchaseError;

  static const String _premiumKey = 'billing_premium_unlocked';

  Future<void> initialize() async {
    // Load saved premium status first
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;

    // Check if billing is available
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      notifyListeners();
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
    );

    // Load products
    await _loadProducts();

    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final Set<String> productIds = {premiumProductId};

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        _errorMessage = 'Could not load products';
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('Exception loading products: $e');
      _errorMessage = 'Error loading products';
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _purchasePending = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        _purchasePending = false;
        _errorMessage = purchaseDetails.error?.message ?? 'Purchase failed';
        notifyListeners();
        onPurchaseError?.call(_errorMessage!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and deliver the product
        bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          await _deliverProduct(purchaseDetails);
        } else {
          _purchasePending = false;
          _errorMessage = 'Purchase verification failed';
          notifyListeners();
          onPurchaseError?.call(_errorMessage!);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _purchasePending = false;
        _errorMessage = 'Purchase was cancelled';
        notifyListeners();
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // For a production app, you should verify the purchase on your server
    // For now, we'll trust the purchase
    return true;
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == premiumProductId) {
      _isPremium = true;
      _purchasePending = false;
      _errorMessage = null;

      // Save premium status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, true);

      notifyListeners();
      onPurchaseSuccess?.call();
    }
  }

  /// Purchase premium
  Future<void> purchasePremium() async {
    if (!_isAvailable) {
      _errorMessage = 'Store not available';
      notifyListeners();
      onPurchaseError?.call(_errorMessage!);
      return;
    }

    final product = premiumProduct;
    if (product == null) {
      _errorMessage = 'Product not found. Please try again later.';
      notifyListeners();
      onPurchaseError?.call(_errorMessage!);
      return;
    }

    _purchasePending = true;
    _errorMessage = null;
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Use buyNonConsumable for one-time purchases like premium unlock
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Purchase error: $e');
      _purchasePending = false;
      _errorMessage = 'Could not start purchase';
      notifyListeners();
      onPurchaseError?.call(_errorMessage!);
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _errorMessage = 'Store not available';
      notifyListeners();
      return;
    }

    _purchasePending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _inAppPurchase.restorePurchases();
      _purchasePending = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Restore error: $e');
      _purchasePending = false;
      _errorMessage = 'Could not restore purchases';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// For testing - manually set premium status
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, status);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
