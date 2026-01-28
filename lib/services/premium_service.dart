import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium_unlocked';
  static final PremiumService _instance = PremiumService._internal();

  factory PremiumService() => _instance;
  PremiumService._internal();

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();
  }

  Future<bool> purchasePremium() async {
    // In a real app, this would integrate with in-app purchases
    // For now, we simulate a successful purchase
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    _isPremium = true;
    notifyListeners();
    return true;
  }

  Future<void> restorePurchase() async {
    // In a real app, this would restore from App Store/Play Store
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();
  }
}