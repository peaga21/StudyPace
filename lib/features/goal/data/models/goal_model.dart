import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    required super.id,
    required super.title,
    required super.description,
    required super.deadline,
    required super.progress,
    required super.createdAt,
    required super.targetMinutes,
    required super.completedMinutes,
    required super.isCompleted,
  });

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