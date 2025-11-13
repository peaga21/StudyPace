class StudyGoal {
  final String id;
  final String title;
  final String description;
  final int targetMinutes;
  final int completedMinutes;
  final DateTime createdAt;
  final bool isCompleted;

  StudyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetMinutes,
    this.completedMinutes = 0,
    required this.createdAt,
    this.isCompleted = false,
  });

  // Método copyWith para imutabilidade
  StudyGoal copyWith({
    String? id,
    String? title,
    String? description,
    int? targetMinutes,
    int? completedMinutes,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return StudyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Converter para Map (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetMinutes': targetMinutes,
      'completedMinutes': completedMinutes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  // Criar a partir de Map
  factory StudyGoal.fromMap(Map<String, dynamic> map) {
    return StudyGoal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetMinutes: map['targetMinutes'] ?? 0,
      completedMinutes: map['completedMinutes'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Progresso em porcentagem
  double get progress {
    if (targetMinutes == 0) return 0.0;
    return (completedMinutes / targetMinutes).clamp(0.0, 1.0);
  }
}