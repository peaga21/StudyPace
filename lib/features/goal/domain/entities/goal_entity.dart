class GoalEntity {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final double progress;
  final DateTime createdAt;
  final int targetMinutes;
  final int completedMinutes;
  final bool isCompleted;

  const GoalEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.progress,
    required this.createdAt,
    required this.targetMinutes,
    required this.completedMinutes,
    required this.isCompleted,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.deadline == deadline &&
        other.progress == progress &&
        other.createdAt == createdAt &&
        other.targetMinutes == targetMinutes &&
        other.completedMinutes == completedMinutes &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        deadline.hashCode ^
        progress.hashCode ^
        createdAt.hashCode ^
        targetMinutes.hashCode ^
        completedMinutes.hashCode ^
        isCompleted.hashCode;
  }
}