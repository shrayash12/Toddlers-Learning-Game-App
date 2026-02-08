import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayTimerService extends ChangeNotifier {
  static final PlayTimerService _instance = PlayTimerService._internal();

  factory PlayTimerService() => _instance;
  PlayTimerService._internal();

  static const String _timeLimitKey = 'play_time_limit_minutes';
  static const String _sessionStartKey = 'play_session_start';
  static const String _isLockedKey = 'play_timer_locked';
  static const String _timerEnabledKey = 'play_timer_enabled';

  Timer? _countdownTimer;

  int _timeLimitMinutes = 30; // Default 30 minutes
  int get timeLimitMinutes => _timeLimitMinutes;

  DateTime? _sessionStartTime;

  bool _isTimerEnabled = false;
  bool get isTimerEnabled => _isTimerEnabled;

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  String get remainingTimeFormatted {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_timeLimitMinutes == 0) return 1.0;
    final totalSeconds = _timeLimitMinutes * 60;
    return _remainingSeconds / totalSeconds;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _timeLimitMinutes = prefs.getInt(_timeLimitKey) ?? 30;
    _isTimerEnabled = prefs.getBool(_timerEnabledKey) ?? false;
    _isLocked = prefs.getBool(_isLockedKey) ?? false;

    if (_isTimerEnabled && !_isLocked) {
      // Check if there's an existing session
      final startTimeMs = prefs.getInt(_sessionStartKey);
      if (startTimeMs != null) {
        _sessionStartTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
        _calculateRemainingTime();
        if (_remainingSeconds > 0) {
          _startCountdown();
        } else {
          await _lockApp();
        }
      } else {
        // Start new session
        await _startNewSession();
      }
    }

    notifyListeners();
  }

  void _calculateRemainingTime() {
    if (_sessionStartTime == null) {
      _remainingSeconds = _timeLimitMinutes * 60;
      return;
    }

    final elapsed = DateTime.now().difference(_sessionStartTime!).inSeconds;
    final totalSeconds = _timeLimitMinutes * 60;
    _remainingSeconds = (totalSeconds - elapsed).clamp(0, totalSeconds);
  }

  Future<void> _startNewSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionStartTime = DateTime.now();
    await prefs.setInt(_sessionStartKey, _sessionStartTime!.millisecondsSinceEpoch);
    _remainingSeconds = _timeLimitMinutes * 60;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _lockApp();
      }
    });
  }

  Future<void> _lockApp() async {
    _isLocked = true;
    _countdownTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLockedKey, true);
    notifyListeners();
  }

  Future<void> setTimeLimit(int minutes) async {
    _timeLimitMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeLimitKey, minutes);
    notifyListeners();
  }

  Future<void> enableTimer(int minutes) async {
    _timeLimitMinutes = minutes;
    _isTimerEnabled = true;
    _isLocked = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeLimitKey, minutes);
    await prefs.setBool(_timerEnabledKey, true);
    await prefs.setBool(_isLockedKey, false);

    await _startNewSession();
    notifyListeners();
  }

  Future<void> disableTimer() async {
    _isTimerEnabled = false;
    _isLocked = false;
    _countdownTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timerEnabledKey, false);
    await prefs.setBool(_isLockedKey, false);
    await prefs.remove(_sessionStartKey);

    notifyListeners();
  }

  Future<void> unlockAndRestart({int? newLimitMinutes}) async {
    _isLocked = false;
    _isTimerEnabled = true;

    if (newLimitMinutes != null) {
      _timeLimitMinutes = newLimitMinutes;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLockedKey, false);
    await prefs.setBool(_timerEnabledKey, true);
    if (newLimitMinutes != null) {
      await prefs.setInt(_timeLimitKey, newLimitMinutes);
    }

    await _startNewSession();
    notifyListeners();
  }

  Future<void> addBonusTime(int minutes) async {
    _remainingSeconds += minutes * 60;

    // Update session start to reflect bonus time
    if (_sessionStartTime != null) {
      _sessionStartTime = _sessionStartTime!.subtract(Duration(minutes: -minutes));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionStartKey, _sessionStartTime!.millisecondsSinceEpoch);
    }

    if (_isLocked) {
      _isLocked = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLockedKey, false);
      _startCountdown();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
