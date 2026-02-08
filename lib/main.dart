import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/premium_service.dart';
import 'services/razorpay_service.dart';
import 'services/screen_lock_service.dart';
import 'services/play_timer_service.dart';
import 'widgets/screen_lock_wrapper.dart';
import 'widgets/play_timer_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PremiumService().initialize();
  await RazorpayService().initialize();
  await ScreenLockService().initialize();
  await PlayTimerService().initialize();
  runApp(const BabyGamesApp());
}

class BabyGamesApp extends StatelessWidget {
  const BabyGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Learning Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SlidePageTransitionsBuilder(),
            TargetPlatform.iOS: SlidePageTransitionsBuilder(),
            TargetPlatform.macOS: SlidePageTransitionsBuilder(),
            TargetPlatform.windows: SlidePageTransitionsBuilder(),
            TargetPlatform.linux: SlidePageTransitionsBuilder(),
          },
        ),
      ),
      home: const AppWithTimerLock(),
    );
  }
}

/// Wrapper that shows timer expired overlay when time is up
class AppWithTimerLock extends StatefulWidget {
  const AppWithTimerLock({super.key});

  @override
  State<AppWithTimerLock> createState() => _AppWithTimerLockState();
}

class _AppWithTimerLockState extends State<AppWithTimerLock> {
  final PlayTimerService _timerService = PlayTimerService();

  @override
  void initState() {
    super.initState();
    _timerService.addListener(_onTimerChange);
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerChange);
    super.dispose();
  }

  void _onTimerChange() {
    setState(() {});
  }

  void _showUnlockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TimerUnlockDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ScreenLockWrapper(child: HomeScreen()),
        // Show timer expired overlay
        if (_timerService.isTimerEnabled && _timerService.isLocked)
          TimerExpiredOverlay(onUnlock: _showUnlockDialog),
      ],
    );
  }
}

/// Custom slide page transition that slides from right when navigating forward
/// and slides from left when navigating back
class SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}
