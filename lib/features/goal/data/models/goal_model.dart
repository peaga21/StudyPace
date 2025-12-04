import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    required String id,
    required String title,
    required String description,
    required DateTime deadline,
    required double progress,
    required DateTime createdAt,
    required int targetMinutes,
    required int completedMinutes,
    required bool isCompleted,
  }) : super(
          id: id,
          title: title,
          description: description,
          deadline: deadline,
          progress: progress,
          createdAt: createdAt,
          targetMinutes: targetMinutes,
          completedMinutes: completedMinutes,
          isCompleted: isCompleted,
        );

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      progress: (json['progress'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      targetMinutes: json['targetMinutes'] ?? 0,
      completedMinutes: json['completedMinutes'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'targetMinutes': targetMinutes,
      'completedMinutes': completedMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      deadline: entity.deadline,
      progress: entity.progress,
      createdAt: entity.createdAt,
      targetMinutes: entity.targetMinutes,
      completedMinutes: entity.completedMinutes,
      isCompleted: entity.isCompleted,
    );
  }
}