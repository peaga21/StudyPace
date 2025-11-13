// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:studypace/core/routes/app_routes.dart';
import 'package:studypace/core/services/prefs_service.dart';
import 'package:studypace/core/theme/app_theme.dart';
import 'package:studypace/services/prefs_service.dart';
import 'package:studypace/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Aguarda 2 segundos para exibir a splash screen
    await Future.delayed(const Duration(seconds: 2));

    final prefs = PrefsService();
    final isAccepted = await prefs.isFullyAccepted();
    final version = await prefs.getAcceptedVersion();

    if (mounted) {
      if (isAccepted && version == 'v1') {
        Navigator.pushReplacementNamed(context, AppRoutes.home!);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text('StudyPace', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            Text('Seu ritmo ideal de estudos', style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  static String? get onboarding => null;
  static String? get home => null;
}