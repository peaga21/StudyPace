import 'package:flutter/material.dart';
import '../models/study_goal.dart';

class GoalCard extends StatelessWidget {
  final StudyGoal goal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder( // ✅ CORREÇÃO AQUI
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: goal.isCompleted
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          child: Icon(
            goal.isCompleted ? Icons.check : Icons.school,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: goal.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              goal.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey[300],
              color: _getProgressColor(goal.progress),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.completedMinutes}/${goal.targetMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(goal.progress),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: onDelete,
        ),
        onTap: onTap,
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