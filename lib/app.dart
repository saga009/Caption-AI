import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'screens/generating/generating_screen.dart';
import 'screens/input/input_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/style/style_screen.dart';

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
        '/home': (context) => const MainShell(),
        '/input': (context) => const InputScreen(),
        '/style': (context) => const StyleScreen(),
        '/generating': (context) => const GeneratingScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}
