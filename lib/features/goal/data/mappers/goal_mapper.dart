import 'package:studypace/features/goal/data/models/study_goal.dart';
// Or create the file at lib/src/models/study_goal.dart if it does not exist.

import '../../domain/entities/goal_entity.dart';

class GoalMapper {
  /// Converte StudyGoal (modelo antigo) para GoalEntity (Clean Architecture)
  static GoalEntity toEntity(StudyGoal studyGoal) {
    return GoalEntity(
      id: studyGoal.id,
      title: studyGoal.title,
      description: studyGoal.description,
      deadline: DateTime.now().add(const Duration(days: 30)), // Valor padrão
      createdAt: studyGoal.createdAt,
      targetMinutes: studyGoal.targetMinutes,
      completedMinutes: studyGoal.completedMinutes,
      isCompleted: studyGoal.isCompleted,
      progress: studyGoal.liveProgress,
    );
  }
  
  /// Converte GoalEntity (Clean Architecture) para StudyGoal (modelo antigo)
  static StudyGoal toStudyGoal(GoalEntity entity) {
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