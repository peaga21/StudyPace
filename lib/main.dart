// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'dart:async';

// Import dos seus arquivos existentes
import 'src/screens/splash_screen.dart';
import 'src/screens/onboarding_screen.dart';
import 'src/screens/policy_viewer_screen.dart';
import 'src/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyPace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}