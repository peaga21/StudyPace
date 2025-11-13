import 'package:flutter/material.dart';
import '../models/study_goal.dart';

class ProgressChart extends StatelessWidget {
  final List<StudyGoal> goals;

  const ProgressChart({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final totalGoals = goals.length;
    
    if (totalGoals == 0) {
      return _buildEmptyChart(context);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso Geral',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildCircularProgress(completedGoals, totalGoals, context),
                      const SizedBox(height: 8),
                      Text(
                        '$completedGoals/$totalGoals metas',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildStatsList(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum dado para mostrar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Crie metas para ver estatísticas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(int completed, int total, BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsList(BuildContext context) {
    final completed = goals.where((goal) => goal.isCompleted).length;
    final inProgress = goals.where((goal) => !goal.isCompleted && goal.completedMinutes > 0).length;
    final notStarted = goals.where((goal) => goal.completedMinutes == 0).length;
    final totalTime = goals.fold(0, (sum, goal) => sum + goal.completedMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem('Concluídas', completed, Colors.green, context),
        _buildStatItem('Em andamento', inProgress, Colors.orange, context),
        _buildStatItem('Não iniciadas', notStarted, Colors.grey, context),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${totalTime ~/ 60}h ${totalTime % 60}m',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }
}