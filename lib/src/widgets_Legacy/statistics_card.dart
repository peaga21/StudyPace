import 'package:flutter/material.dart';
import 'package:studypace/features/goal/data/models/study_goal.dart';
import 'package:studypace/src/services_Legacy/ai_insight_service.dart';

class StatisticsCard extends StatelessWidget {
  final List<StudyGoal> goals;
  final AIInsightService aiService = AIInsightService();

  StatisticsCard({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final stats = aiService.generateDetailedStats(goals);
    final message = aiService.generateMotivationalMessage(goals);

    return Column(
      children: [
        // Card de Insights da IA
        Card(
          elevation: 2,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Insight do Dia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[900],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Grid de Estatísticas
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Metas Totais',
              stats['totalGoals'].toString(),
              Icons.flag,
              Colors.blue,
              context,
            ),
            _buildStatCard(
              'Concluídas',
              '${stats['completedGoals']}/${stats['totalGoals']}',
              Icons.check_circle,
              Colors.green,
              context,
            ),
            _buildStatCard(
              'Taxa de Conclusão',
              '${stats['completionRate'].toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange,
              context,
            ),
            _buildStatCard(
              'Tempo Estudado',
              '${stats['totalCompletedTime']}m',
              Icons.timer,
              Colors.purple,
              context,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}