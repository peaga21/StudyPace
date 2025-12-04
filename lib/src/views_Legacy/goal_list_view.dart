import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypace/features/goal/data/models/study_goal.dart';
import 'package:studypace/features/goal/presentation/providers/goal_provider.dart';
import '../widgets_Legacy/goal_card.dart';
import '../widgets_Legacy/empty_state.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Estudo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botão debug (remover depois)
          /*IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              context.read<GoalController>().debugPrintGoals();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metas impressas no console')),
              );
            },
          ),*/
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
            tooltip: 'Ver Dashboard',
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading && goalProvider.goals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (goalProvider.error != null && goalProvider.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${goalProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: goalProvider.loadGoals,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (goalProvider.goals.isEmpty) {
            return const EmptyStateWidget();
          }

          return RefreshIndicator(
            onRefresh: () => goalProvider.loadGoals(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goalProvider.goals.length,
              itemBuilder: (context, index) {
                final goal = goalProvider.goals[index];
                return GoalCard(
                  goal: goal,
                  onTap: () => _showGoalDetails(context, goal),
                  onDelete: () => _deleteGoal(context, goal),
                );
              },
            ),
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
            Text(
              goal.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('Meta total:', '${goal.targetMinutes} minutos'),
            _buildDetailItem('Completado:', '${goal.completedMinutes} minutos'),
            const SizedBox(height: 8),
            LinearProgressIndicator( // Use liveProgress for real-time updates
              value: goal.liveProgress,
              backgroundColor: Colors.grey[300],
              color: _getProgressColor(goal.liveProgress),
            ),
            const SizedBox(height: 8),
            Text(
              '${(goal.liveProgress * 100).toStringAsFixed(1)}% completo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(goal.liveProgress),
              ),
            ),
            if (goal.isCompleted) ...[
              const SizedBox(height: 8),
              // ✅ CORRIGIDO - Container sem conflito shape/borderRadius
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8), // ✅ APENAS borderRadius
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Meta concluída!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () => _updateProgress(context, goal),
            child: const Text('Atualizar Progresso'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  void _updateProgress(BuildContext context, StudyGoal goal) {
    final textController = TextEditingController(text: goal.completedMinutes.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Progresso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos estudados',
                hintText: 'Ex: 30',
                suffixText: 'minutos',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progresso atual: ${goal.completedMinutes}/${goal.targetMinutes}min (${(goal.liveProgress * 100).toStringAsFixed(1)}%)',
              style: TextStyle( // Use liveProgress for real-time updates
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (goal.targetMinutes > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Faltam: ${goal.targetMinutes - goal.completedMinutes}min para completar',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutesText = textController.text.trim();
              final minutes = int.tryParse(minutesText);
              
              if (minutesText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digite a quantidade de minutos!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (minutes == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digite um número válido!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (minutes < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Os minutos não podem ser negativos!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Atualizar progresso
              context.read<GoalProvider>().addStudyTime(minutes); // Assuming addStudyTime is the correct method
              Navigator.pop(context); // Fecha dialog de progresso
              Navigator.pop(context); // Fecha dialog de detalhes
              
              // Mostrar confirmação
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Progresso atualizado: $minutes minutos'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Salvar Progresso'),
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
              context.read<GoalProvider>().deleteGoal(goal.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Meta "${goal.title}" deletada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}