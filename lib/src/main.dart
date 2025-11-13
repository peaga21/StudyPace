import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports das novas features
import 'package:studypace/src/controllers/goal_controller.dart';
import 'package:studypace/src/repositories/local_study_goal_repository.dart';
import 'package:studypace/src/services/goal_service.dart';
import 'package:studypace/src/services/notification_service.dart';
import 'package:studypace/src/views/goal_list_view.dart';
import 'package:studypace/src/views/dashboard_view.dart';
import 'package:studypace/src/views/reminder_settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificações
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar dependências
    final repository = LocalStudyGoalRepository();
    final service = GoalService(repository);
    final goalController = GoalController(service);

    return ChangeNotifierProvider(
      create: (context) => goalController,
      child: MaterialApp(
        title: 'StudyPace - Metas de Estudo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        // Tela inicial direto nas metas
        home: const GoalListView(),
        // Rotas para navegação
        routes: {
          '/goals': (context) => const GoalListView(),
          '/dashboard': (context) => const DashboardView(),
          '/reminders': (context) => const ReminderSettingsView(),
        },
      ),
    );
  }
}