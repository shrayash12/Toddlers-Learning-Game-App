import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PremiumService().initialize();
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
      ),
      home: const HomeScreen(),
    );
  }
}
