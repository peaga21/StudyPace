import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypace/core/theme/app_theme.dart';
import 'package:studypace/src/Screens_Legacy/onboarding_screen.dart';
import 'package:studypace/src/Screens_Legacy/policy_viewer_screen.dart';
import 'package:studypace/src/Screens_Legacy/splash_screen.dart';
import 'dart:async';
import 'injection/injector.dart';
import 'features/goal/presentation/providers/goal_provider.dart';
import 'features/goal/presentation/screens/home_screen_clean.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider do módulo Goal (Clean Architecture)
        ChangeNotifierProvider(
          create: (context) => getIt<GoalProvider>(),
        ),
        // Adicione outros providers aqui conforme for migrando
      ],
      child: MaterialApp(
        title: 'StudyPace',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Rota inicial (fluxo completo do app)
        home: const SplashScreen(),
        
        debugShowCheckedModeBanner: false,
        
        // Rotas nomeadas para navegação
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/policy': (context) => const PolicyViewerScreen(),
          '/home': (context) => const HomeScreenClean(),
        },
      ),
    );
  }
}