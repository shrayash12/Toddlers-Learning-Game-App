import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RazorpayService extends ChangeNotifier {
  static final RazorpayService _instance = RazorpayService._internal();

  // Razorpay API Keys - Replace with your actual keys from Razorpay Dashboard
  // Get your keys at: https://dashboard.razorpay.com/
  // Use Test Key for testing, Live Key for production
  static const String _testKeyId = 'rzp_test_YOUR_TEST_KEY';
  static const String _liveKeyId = 'rzp_live_YOUR_LIVE_KEY';

  // Set to false for production
  static const bool _useTestMode = true;

  String get _keyId => _useTestMode ? _testKeyId : _liveKeyId;

  // Premium price in paise (100 paise = 1 INR)
  // Set your price here (e.g., 29900 = Rs. 299)
  static const int premiumPriceInPaise = 29900;
  static const String premiumPriceDisplay = '\u20B9299';

  factory RazorpayService() => _instance;
  RazorpayService._internal();

  Razorpay? _razorpay;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _paymentPending = false;
  bool get paymentPending => _paymentPending;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _lastPaymentId;
  String? get lastPaymentId => _lastPaymentId;

  // Callbacks
  Function(String paymentId)? onPaymentSuccess;
  Function(String errorMessage)? onPaymentError;

  static const String _premiumKey = 'razorpay_premium_unlocked';
  static const String _paymentIdKey = 'razorpay_payment_id';

  Future<void> initialize() async {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Load saved premium status
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    _lastPaymentId = prefs.getString(_paymentIdKey);
    notifyListeners();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');

    _paymentPending = false;
    _isPremium = true;
    _lastPaymentId = response.paymentId;
    _errorMessage = null;

    // Save premium status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    if (response.paymentId != null) {
      await prefs.setString(_paymentIdKey, response.paymentId!);
    }

    notifyListeners();
    onPaymentSuccess?.call(response.paymentId ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');

    _paymentPending = false;

    switch (response.code) {
      case Razorpay.NETWORK_ERROR:
        _errorMessage = 'Network error. Please check your connection.';
        break;
      case Razorpay.INVALID_OPTIONS:
        _errorMessage = 'Invalid payment options.';
        break;
      case Razorpay.PAYMENT_CANCELLED:
        _errorMessage = 'Payment was cancelled.';
        break;
      case Razorpay.TLS_ERROR:
        _errorMessage = 'Security error. Please try again.';
        break;
      default:
        _errorMessage = response.message ?? 'Payment failed. Please try again.';
    }

    notifyListeners();
    onPaymentError?.call(_errorMessage!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    // Handle external wallet selection if needed
  }

  /// Open Razorpay payment checkout
  void openCheckout({
    required String name,
    required String description,
    required String email,
    required String phone,
    int? amountInPaise,
  }) {
    if (_razorpay == null) {
      _errorMessage = 'Payment service not initialized';
      notifyListeners();
      return;
    }

    _paymentPending = true;
    _errorMessage = null;
    notifyListeners();

    var options = {
      'key': _keyId,
      'amount': amountInPaise ?? premiumPriceInPaise,
      'name': 'Baby Learning Games',
      'description': description,
      'prefill': {
        'contact': phone,
        'email': email,
      },
      'theme': {
        'color': '#FF9800', // Orange color
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
        'emi': false,
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      _paymentPending = false;
      _errorMessage = 'Could not open payment gateway';
      notifyListeners();
    }
  }

  /// Quick checkout for premium unlock
  void purchasePremium({
    String email = '',
    String phone = '',
  }) {
    openCheckout(
      name: 'Premium Bundle',
      description: 'Unlock all premium games - Lifetime access',
      email: email,
      phone: phone,
    );
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

  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}
