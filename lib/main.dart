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
  // 1. Garante que a engine do Flutter está pronta antes de qualquer coisa
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("--- INICIANDO SETUP INJECTOR ---");
    // 2. Tenta iniciar a injeção de dependência
    await setupInjector();
    print("--- SETUP INJECTOR SUCESSO ---");
    
    // 3. Se passou daqui, roda o app
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // 4. Se der erro no setupInjector, vai aparecer aqui
    print("!!! ERRO FATAL AO INICIAR O APP !!!");
    print("Erro: $e");
    print("Stack: $stackTrace");
    
    // Opcional: Roda um app de erro visual para você saber que falhou
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Erro ao iniciar: $e", textAlign: TextAlign.center),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ATENÇÃO: Se o GoalProvider não estiver registrado no injector.dart,
        // o app vai quebrar assim que tentar usar este Provider.
        ChangeNotifierProvider(
          create: (context) {
            try {
              return getIt<GoalProvider>();
            } catch (e) {
              print("Erro ao buscar GoalProvider no GetIt: $e");
              rethrow;
            }
          },
        ),
      ],
      child: MaterialApp(
        title: 'StudyPace',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        home: const SplashScreen(),
        
        debugShowCheckedModeBanner: false,
        
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