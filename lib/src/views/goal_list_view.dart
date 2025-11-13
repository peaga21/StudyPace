// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/goal_controller.dart';
import '../models/study_goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/empty_state.dart';
import 'goal_form_view.dart';

class GoalListView extends StatefulWidget {
  const GoalListView({super.key});

  @override
  State<GoalListView> createState() => _GoalListViewState();
}

class _GoalListViewState extends State<GoalListView> {
  @override
  void initState() {
    super.initState();
    // Carregar metas quando a tela iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalController>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Estudo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GoalController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.goals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null && controller.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${controller.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadGoals,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (controller.goals.isEmpty) {
            return const Center(child: Text('Nenhuma meta cadastrada.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.goals.length,
            itemBuilder: (context, index) {
              final goal = controller.goals[index];
              return GoalCard(
                goal: goal,
                onTap: () => _showGoalDetails(context, goal),
                onDelete: () => _deleteGoal(context, goal),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GoalFormView(),
    );
  }

  void _showGoalDetails(BuildContext context, StudyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description),
            const SizedBox(height: 16),
            Text('Meta: ${goal.targetMinutes} minutos'),
            Text('Completado: ${goal.completedMinutes} minutos'),
            LinearProgressIndicator(
              value: goal.progress,
            ),
            Text('${(goal.progress * 100).toStringAsFixed(1)}% completo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(BuildContext context, StudyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Meta'),
        content: Text('Tem certeza que deseja deletar "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalController>().deleteGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}