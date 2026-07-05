import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/input/input_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/splash/splash_screen.dart';

class CaptionAIApp extends StatelessWidget {
  const CaptionAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caption AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/input': (context) => const InputScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}
