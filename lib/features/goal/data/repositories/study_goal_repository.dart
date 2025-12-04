import '../../domain/entities/goal_entity.dart';

/// Interface do repositório LEGADO - Mantida para compatibilidade
/// Esta é a interface que seu código antigo usa
abstract class StudyGoalRepository {
  // Buscar todas as metas
  Future<List<GoalEntity>> getAllGoals();
  
  // Buscar meta por ID
  Future<GoalEntity?> getGoalById(String id);
  
  // Salvar meta (criar ou atualizar)
  Future<void> saveGoal(GoalEntity goal);
  
  // Deletar meta
  Future<void> deleteGoal(String id);
  
  // Atualizar progresso
  Future<void> updateProgress(String id, int minutesCompleted);
}