import '../models/study_goal.dart';
import '../repositories/study_goal_repository.dart';

class GoalService {
  final StudyGoalRepository _repository;

  GoalService(this._repository);

  // Criar nova meta
  Future<StudyGoal> createGoal({
    required String title,
    required String description,
    required int targetMinutes,
  }) async {
    final goal = StudyGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      targetMinutes: targetMinutes,
      createdAt: DateTime.now(),
    );
    
    await _repository.saveGoal(goal);
    return goal;
  }

  // Buscar todas as metas ordenadas por data
  Future<List<StudyGoal>> getGoalsSortedByDate() async {
    final goals = await _repository.getAllGoals();
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  // Calcular estatísticas
  Future<Map<String, dynamic>> getStatistics() async {
    final goals = await _repository.getAllGoals();
    final totalGoals = goals.length;
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final totalTargetTime = goals.fold(0, (sum, goal) => sum + goal.targetMinutes);
    final totalCompletedTime = goals.fold(0, (sum, goal) => sum + goal.completedMinutes);
    
    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0,
      'totalTargetTime': totalTargetTime,
      'totalCompletedTime': totalCompletedTime,
    };
  }

  // Validar meta
  String? validateGoal(String title, String description, String targetMinutes) {
    if (title.isEmpty) return 'Título é obrigatório';
    if (description.isEmpty) return 'Descrição é obrigatória';
    if (targetMinutes.isEmpty || int.tryParse(targetMinutes) == null) {
      return 'Tempo alvo deve ser um número válido';
    }
    if (int.parse(targetMinutes) <= 0) {
      return 'Tempo alvo deve ser maior que zero';
    }
    return null;
  }

  Future<void> deleteGoal(String goalId) async {}

  Future<void> updateProgress(String goalId, int minutesCompleted) async {}
}