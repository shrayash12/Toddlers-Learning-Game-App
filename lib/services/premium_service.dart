import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium_unlocked';
  static final PremiumService _instance = PremiumService._internal();

  // Product ID - must match the ID configured in App Store Connect / Google Play Console
  static const String premiumProductId = 'premium_games_bundle';

  factory PremiumService() => _instance;
  PremiumService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isAvailable = false;
  bool get isStoreAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _purchasePending = false;
  bool get purchasePending => _purchasePending;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    // Load saved premium status
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;

    // Check if store is available
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      // Listen to purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _onPurchaseDone,
        onError: _onPurchaseError,
      );

      // Load products
      await _loadProducts();
    }

    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final Set<String> productIds = {premiumProductId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    notifyListeners();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error);
          _purchasePending = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndDeliverPurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  void _onPurchaseError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  void _handleError(IAPError? error) {
    _errorMessage = error?.message ?? 'Purchase failed';
    _purchasePending = false;
    notifyListeners();
  }

  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    // In a production app, verify the purchase with your server
    // For now, we trust the purchase and unlock premium
    if (purchaseDetails.productID == premiumProductId) {
      await _unlockPremium();
    }
    _purchasePending = false;
    notifyListeners();
  }

  Future<void> _unlockPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    _isPremium = true;
    notifyListeners();
  }

  Future<bool> purchasePremium() async {
    if (!_isAvailable) {
      // Store not available - for testing, simulate purchase
      await _unlockPremium();
      return true;
    }

    if (_products.isEmpty) {
      // No products loaded - for testing, simulate purchase
      await _unlockPremium();
      return true;
    }

    // Find the premium product
    final ProductDetails? product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => _products.first,
    );

    if (product == null) {
      await _unlockPremium();
      return true;
    }

    // Start the purchase
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      debugPrint('Purchase error: $e');
      // For testing, simulate purchase on error
      await _unlockPremium();
      return true;
    }
  }

  Future<void> restorePurchase() async {
    if (_isAvailable) {
      await _inAppPurchase.restorePurchases();
    } else {
      // Check local storage
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
