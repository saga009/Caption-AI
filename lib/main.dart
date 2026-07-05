import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/providers/caption_provider.dart';
import 'core/providers/generation_limit_provider.dart';
import 'core/services/admob_service.dart';

// Firebase setup: run `flutterfire configure` to generate firebase_options.dart
// then uncomment the two lines below and add firebase_options.dart import
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Uncomment after running `flutterfire configure`:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AdmobService.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CaptionProvider()),
        ChangeNotifierProvider(create: (_) => GenerationLimitProvider()),
      ],
      child: const CaptionAIApp(),
    ),
  );
}
