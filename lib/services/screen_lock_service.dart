import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenLockService extends ChangeNotifier {
  static final ScreenLockService _instance = ScreenLockService._internal();

  factory ScreenLockService() => _instance;
  ScreenLockService._internal();

  static const String _lockEnabledKey = 'screen_lock_enabled';

  bool _isLockEnabled = false;
  bool get isLockEnabled => _isLockEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLockEnabled = prefs.getBool(_lockEnabledKey) ?? false;
    notifyListeners();
  }

  Future<void> setLockEnabled(bool enabled) async {
    _isLockEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> toggleLock() async {
    await setLockEnabled(!_isLockEnabled);
  }
}
