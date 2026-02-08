import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/premium_service.dart';
import 'services/screen_lock_service.dart';
import 'widgets/screen_lock_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PremiumService().initialize();
  await ScreenLockService().initialize();
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
      home: const ScreenLockWrapper(child: HomeScreen()),
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
