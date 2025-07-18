// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/app_theme.dart';
import 'package:smart_calorie_flutter/auth_gate.dart';
import 'package:smart_calorie_flutter/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calor',
      theme: AppTheme.theme, // Correctly uses the 'theme' getter
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}