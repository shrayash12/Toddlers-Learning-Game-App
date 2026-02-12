import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Legacy PremiumService - kept for backwards compatibility
/// New purchases are handled by BillingService
class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();

  factory PremiumService() => _instance;
  PremiumService._internal();

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const String _premiumKey = 'premium_unlocked';

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('PremiumService initialization error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set premium status (called by BillingService on successful purchase)
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, status);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
