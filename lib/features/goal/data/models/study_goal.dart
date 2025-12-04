/// Representa uma meta de estudo com tracking em tempo real.
class StudyGoal {
  final String id;
  final String title;
  final String description;
  final int targetMinutes;
  int completedMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  // Controle de tempo real
  bool _isTracking = false;
  int _liveSeconds = 0;

  StudyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetMinutes,
    this.completedMinutes = 0,
    required this.createdAt,
    this.completedAt,
  });

  /// Iniciar tracking em tempo real
  void startTracking() {
    if (!_isTracking) {
      _isTracking = true;
      _liveSeconds = 0;
    }
  }

  /// Parar tracking e salvar tempo acumulado
  void stopTracking() {
    if (_isTracking) {
      // Converter segundos acumulados para minutos
      final additionalMinutes = _liveSeconds ~/ 60;
      if (additionalMinutes > 0) {
        completedMinutes += additionalMinutes;
      }
      _isTracking = false;
      _liveSeconds = 0;
    }
  }

  /// Adicionar 1 segundo em tempo real
  void addLiveSecond() {
    if (_isTracking) {
      _liveSeconds++;
    }
  }

  /// Adicionar tempo manualmente (ex: quando completa Pomodoro)
  void addStudyTime(int minutes) {
    completedMinutes += minutes;
  }

  /// GETTER para minutos completos em tempo real
  int get liveCompletedMinutes {
    int total = completedMinutes;
    if (_isTracking) {
      total += _liveSeconds ~/ 60;
    }
    return total;
  }

  /// GETTER para progresso em tempo real
  double get liveProgress {
    if (targetMinutes == 0) return 0.0;
    double progress = liveCompletedMinutes / targetMinutes;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Verifica se a meta está completa
  bool get isCompleted => completedMinutes >= targetMinutes;

  /// Método copyWith para imutabilidade
  StudyGoal copyWith({
    String? id,
    String? title,
    String? description,
    int? targetMinutes,
    int? completedMinutes,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? resetTracking = false,
  }) {
    final newGoal = StudyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
    
    // Se resetTracking for true, mantém o tracking estado
    if (resetTracking != true && _isTracking) {
      newGoal._isTracking = true;
      newGoal._liveSeconds = _liveSeconds;
    }
    
    return newGoal;
  }

  /// Converter para Map (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetMinutes': targetMinutes,
      'completedMinutes': completedMinutes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'isTracking': _isTracking,
      'liveSeconds': _liveSeconds,
    };
  }

  /// Criar a partir de Map
  factory StudyGoal.fromMap(Map<String, dynamic> map) {
    final goal = StudyGoal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetMinutes: map['targetMinutes'] ?? 0,
      completedMinutes: map['completedMinutes'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
    );
    
    // Restaura estado de tracking
    if (map['isTracking'] == true) {
      goal._isTracking = true;
      goal._liveSeconds = map['liveSeconds'] ?? 0;
    }
    
    return goal;
  }

  /// Converter para JSON (alias para toMap)
  Map<String, dynamic> toJson() => toMap();

  /// Criar a partir de JSON (alias para fromMap)
  factory StudyGoal.fromJson(Map<String, dynamic> json) => StudyGoal.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is StudyGoal &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.targetMinutes == targetMinutes &&
        other.completedMinutes == completedMinutes &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other._isTracking == _isTracking &&
        other._liveSeconds == _liveSeconds;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        targetMinutes.hashCode ^
        completedMinutes.hashCode ^
        createdAt.hashCode ^
        completedAt.hashCode ^
        _isTracking.hashCode ^
        _liveSeconds.hashCode;
  }

  @override
  String toString() {
    return 'StudyGoal(id: $id, title: $title, progress: ${(liveProgress * 100).toStringAsFixed(1)}%, tracking: $_isTracking)';
  }
}