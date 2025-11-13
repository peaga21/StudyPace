import '../models/study_goal.dart';

abstract class StudyGoalRepository {
  // Buscar todas as metas
  Future<List<StudyGoal>> getAllGoals();
  
  // Buscar meta por ID
  Future<StudyGoal?> getGoalById(String id);
  
  // Salvar meta (criar ou atualizar)
  Future<void> saveGoal(StudyGoal goal);
  
  // Deletar meta
  Future<void> deleteGoal(String id);
  
  // Atualizar progresso
  Future<void> updateProgress(String id, int minutesCompleted);
}