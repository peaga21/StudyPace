import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypace/core/routes/app_routes.dart';
import 'package:studypace/core/theme/app_theme.dart';
import 'package:studypace/features/home/presenter/providers/study_provider.dart';
import 'package:studypace/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // O [ChangeNotifierProvider] disponibiliza o [StudyProvider] para toda a
    // árvore de widgets abaixo dele.
    return ChangeNotifierProvider(
      create: (context) => StudyProvider(),
      child: MaterialApp(
        title: 'StudyPace',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Define a tela inicial e as rotas nomeadas do app.
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}