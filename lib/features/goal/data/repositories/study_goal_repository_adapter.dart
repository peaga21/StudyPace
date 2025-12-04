import 'package:studypace/features/goal/data/models/study_goal.dart';
import 'package:studypace/features/goal/data/repositories/study_goal_repository.dart';

import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

/// Adapter que converte StudyGoalRepository (legado) para GoalRepository (Clean Architecture)
class StudyGoalRepositoryAdapter implements GoalRepository {
  final StudyGoalRepository _studyGoalRepository;
  
  StudyGoalRepositoryAdapter(this._studyGoalRepository);
  
  @override
  Future<List<GoalEntity>> getGoals() async {
    try {
      // 1. Busca StudyGoals do repositório legado
      final studyGoals = await _studyGoalRepository.getAllGoals();
      
      // 2. Converte cada StudyGoal para GoalEntity
      return studyGoals.map((e) => _convertToEntity(e as StudyGoal)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas: $e');
    }
  }
  
  @override
  Future<GoalEntity> getGoalById(String id) async {
    try {
      final studyGoal = await _studyGoalRepository.getGoalById(id);
      if (studyGoal == null) {
        throw Exception('Meta não encontrada com ID: $id');
      }
      return _convertToEntity(studyGoal as StudyGoal);
    } catch (e) {
      throw Exception('Erro ao buscar meta por ID: $e');
    }
  }
  
  @override
  Future<GoalEntity> createGoal(GoalEntity goal) async {
    try {
      // Converte GoalEntity para StudyGoal
      final studyGoal = _convertToStudyGoal(goal); // Fix: The argument type 'GoalEntity' can't be assigned to the parameter type 'StudyGoal'.
      await _studyGoalRepository.saveGoal(studyGoal as GoalEntity);
      return goal;
    } catch (e) {
      throw Exception('Erro ao criar meta: $e');
    }
  }
  
  @override
  Future<GoalEntity> updateGoal(GoalEntity goal) async {
    try {
      // Converte GoalEntity para StudyGoal
      final studyGoal = _convertToStudyGoal(goal);
      await _studyGoalRepository.saveGoal(studyGoal as GoalEntity);
      return goal;
    } catch (e) {
      throw Exception('Erro ao atualizar meta: $e');
    }
  }
  
  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _studyGoalRepository.deleteGoal(id);
    } catch (e) {
      throw Exception('Erro ao deletar meta: $e');
    }
  }
  
  // ========== MÉTODOS PRIVADOS DE CONVERSÃO ==========
  
  /// Converte StudyGoal (legado) para GoalEntity (Clean Architecture)
  GoalEntity _convertToEntity(StudyGoal studyGoal) {
    return GoalEntity(
      id: studyGoal.id,
      title: studyGoal.title,
      description: studyGoal.description,
      deadline: DateTime.now().add(const Duration(days: 30)),
      progress: studyGoal.liveProgress,
      createdAt: studyGoal.createdAt,
      targetMinutes: studyGoal.targetMinutes,
      completedMinutes: studyGoal.completedMinutes,
      isCompleted: studyGoal.isCompleted,
    );
  }
  
  /// Converte GoalEntity (Clean Architecture) para StudyGoal (legado)
  StudyGoal _convertToStudyGoal(GoalEntity entity) {
    return StudyGoal(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      targetMinutes: entity.targetMinutes,
      completedMinutes: entity.completedMinutes,
      createdAt: entity.createdAt,
      completedAt: entity.isCompleted ? DateTime.now() : null,
    );
  }
}