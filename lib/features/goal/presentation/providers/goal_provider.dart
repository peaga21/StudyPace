import 'package:flutter/foundation.dart';
import 'package:studypace/features/goal/data/models/study_goal.dart';
import '../../domain/usecases/get_goals_usecase.dart';
import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/update_goal_usecase.dart';
import '../../domain/usecases/delete_goal_usecase.dart';
import '../../domain/entities/goal_entity.dart';

class GoalProvider with ChangeNotifier {
  final GetGoalsUseCase _getGoalsUseCase;
  final CreateGoalUseCase _createGoalUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final DeleteGoalUseCase _deleteGoalUseCase;
  
  List<StudyGoal> _goals = [];
  bool _isLoading = false;
  String? _error;
  StudyGoal? _currentTrackingGoal;
  bool _isTracking = false;
  
  GoalProvider(
    this._getGoalsUseCase,
    this._createGoalUseCase,
    this._updateGoalUseCase,
    this._deleteGoalUseCase,
  ) {
    // Inicializa com dados de exemplo imediatamente
    _initializeGoals();
  }
  
  // ========== GETTERS ==========
  List<StudyGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StudyGoal? get currentTrackingGoal => _currentTrackingGoal;
  bool get isTracking => _isTracking;
  
  // ========== MÉTODOS PÚBLICOS ==========
  
  /// Carrega metas do repositório OU usa dados de exemplo
  Future<void> loadGoals() async {
    print('🔍 GoalProvider.loadGoals() chamado');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('📞 Tentando buscar do repositório...');
      final goalEntities = await _getGoalsUseCase();
      print('✅ Repositório retornou ${goalEntities.length} metas');
      
      if (goalEntities.isNotEmpty) {
        _goals = goalEntities.map(_convertToStudyGoal).toList();
        print('📊 ${_goals.length} metas carregadas com sucesso');
      } else {
        print('⚠️ Repositório vazio, usando dados de exemplo');
        _addSampleGoals();
      }
      
      _error = null;
    } catch (e) {
      print('❌ ERRO no loadGoals: $e');
      print('🔄 Usando dados de exemplo devido ao erro');
      _addSampleGoals();
      _error = 'Carregando dados locais...';
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 loadGoals() finalizado com ${_goals.length} metas');
    }
  }
  
  /// Inicializa com metas imediatamente (para UI responsiva)
  void _initializeGoals() {
    print('🎯 Inicializando GoalProvider...');
    
    // Adiciona dados de exemplo imediatamente
    if (_goals.isEmpty) {
      _addSampleGoals();
      print('✅ ${_goals.length} metas de exemplo inicializadas');
    }
    
    // Depois tenta carregar do repositório
    Future.delayed(const Duration(milliseconds: 500), () {
      loadGoals();
    });
  }
  
  /// Adiciona metas de exemplo garantidas
  void _addSampleGoals() {
    // Limpa primeiro para não duplicar
    _goals.clear();
    
    final sampleGoals = [
      StudyGoal(
        id: 'sample-1-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Estudar Clean Architecture',
        description: 'Implementar no projeto StudyPace',
        targetMinutes: 180,
        completedMinutes: 60,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      StudyGoal(
        id: 'sample-2-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Preparar apresentação final',
        description: 'Criar slides e demonstrar funcionalidades',
        targetMinutes: 120,
        completedMinutes: 30,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      StudyGoal(
        id: 'sample-3-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Aprender Flutter Avançado',
        description: 'Widgets customizados, animações e estado',
        targetMinutes: 240,
        completedMinutes: 120,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      StudyGoal(
        id: 'sample-4-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Revisar Dart Programming',
        description: 'Conceitos fundamentais e boas práticas',
        targetMinutes: 90,
        completedMinutes: 90,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    
    _goals.addAll(sampleGoals);
    print('➕ ${sampleGoals.length} metas de exemplo adicionadas');
  }
  
  /// Cria e salva uma nova meta
  Future<void> addGoal(StudyGoal goal) async {
    try {
      print('➕ Criando nova meta: ${goal.title}');
      
      // Adiciona localmente primeiro (para UI responsiva)
      _goals.add(goal);
      notifyListeners();
      
      // Tenta salvar no repositório
      final goalEntity = _convertToEntity(goal);
      await _createGoalUseCase(goalEntity);
      
      print('✅ Meta "${goal.title}" criada e salva');
      _showSuccess('Meta criada com sucesso!');
      
    } catch (e) {
      print('⚠️ Erro ao salvar no repositório (mantendo local): $e');
      _showError('Meta criada (salvamento local)');
    }
  }
  
  /// Atualiza uma meta existente
  Future<void> updateGoal(StudyGoal goal) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
        
        final goalEntity = _convertToEntity(goal);
        await _updateGoalUseCase(goalEntity);
        
        print('✅ Meta "${goal.title}" atualizada');
      }
    } catch (e) {
      print('⚠️ Erro ao atualizar meta: $e');
    }
  }
  
  /// Deleta uma meta
  Future<void> deleteGoal(String goalId) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      _goals.removeWhere((g) => g.id == goalId);
      
      if (_currentTrackingGoal?.id == goalId) {
        _currentTrackingGoal = null;
        _isTracking = false;
      }
      
      notifyListeners();
      
      await _deleteGoalUseCase(goalId);
      print('🗑️ Meta "${goal.title}" deletada');
      _showSuccess('Meta deletada!');
      
    } catch (e) {
      print('⚠️ Erro ao deletar meta: $e');
      _showError('Erro ao deletar meta');
    }
  }
  
  /// Inicia tracking de uma meta
  Future<void> startTrackingGoal(StudyGoal goal) async {
    _currentTrackingGoal?.stopTracking();
    _currentTrackingGoal = goal;
    _isTracking = true;
    goal.startTracking();
    notifyListeners();
    
    print('⏰ Iniciando tracking: ${goal.title}');
    _showSuccess('Rastreando "${goal.title}"');
  }
  
  /// Para tracking e salva progresso
  Future<void> stopTrackingGoal() async {
    if (_currentTrackingGoal != null) {
      final goal = _currentTrackingGoal!;
      goal.stopTracking();
      
      try {
        final goalEntity = _convertToEntity(goal);
        await _updateGoalUseCase(goalEntity);
        print('⏹️ Tracking parado: ${goal.title}');
      } catch (e) {
        print('⚠️ Erro ao salvar progresso: $e');
      }
      
      _currentTrackingGoal = null;
      _isTracking = false;
      notifyListeners();
      
      _showSuccess('Tracking parado');
    }
  }
  
  /// Adiciona tempo de estudo
  Future<void> addStudyTime(int minutes) async {
    if (_currentTrackingGoal != null) {
      _currentTrackingGoal!.addStudyTime(minutes);
      
      try {
        final goalEntity = _convertToEntity(_currentTrackingGoal!);
        await _updateGoalUseCase(goalEntity);
      } catch (e) {
        print('⚠️ Erro ao salvar tempo: $e');
      }
      
      notifyListeners();
      print('➕ Adicionados $minutes min à meta "${_currentTrackingGoal!.title}"');
    }
  }
  
  /// Atualiza progresso em tempo real
  void updateLiveProgress() {
    if (_isTracking && _currentTrackingGoal != null) {
      _currentTrackingGoal!.addLiveSecond();
      notifyListeners();
    }
  }
  
  /// Limpa mensagens de erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Estatísticas para dashboard
  Map<String, dynamic> get statistics {
    final total = _goals.length;
    final completed = _goals.where((g) => g.isCompleted).length;
    final totalTargetMinutes = _goals.fold(0, (sum, goal) => sum + goal.targetMinutes);
    final totalCompletedMinutes = _goals.fold(0, (sum, goal) => sum + goal.completedMinutes);
    final overallProgress = totalTargetMinutes > 0 ? totalCompletedMinutes / totalTargetMinutes : 0.0;
    
    return {
      'totalGoals': total,
      'completedGoals': completed,
      'completionRate': total > 0 ? (completed / total) * 100 : 0,
      'totalTargetTime': totalTargetMinutes,
      'totalCompletedTime': totalCompletedMinutes,
      'overallProgress': overallProgress,
      'activeGoals': total - completed,
    };
  }
  
  // ========== MÉTODOS PRIVADOS ==========
  
  /// Converte StudyGoal para GoalEntity
  GoalEntity _convertToEntity(StudyGoal goal) {
    return GoalEntity(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      deadline: DateTime.now().add(const Duration(days: 30)),
      progress: goal.liveProgress,
      createdAt: goal.createdAt,
      targetMinutes: goal.targetMinutes,
      completedMinutes: goal.completedMinutes,
      isCompleted: goal.isCompleted,
    );
  }
  
  /// Converte GoalEntity para StudyGoal
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
  
  /// Helper para mostrar sucesso (simulado)
  void _showSuccess(String message) {
    print('✅ $message');
  }
  
  /// Helper para mostrar erro (simulado)
  void _showError(String message) {
    print('❌ $message');
  }
  
  /// Método de depuração
  void debugInfo() {
    print('\n=== DEBUG GOALPROVIDER ===');
    print('Total metas: ${_goals.length}');
    print('Carregando: $_isLoading');
    print('Tracking: $_isTracking');
    print('Meta atual: ${_currentTrackingGoal?.title ?? "Nenhuma"}');
    for (var goal in _goals) {
      print('  - ${goal.title}: ${goal.liveCompletedMinutes}/${goal.targetMinutes}min (${(goal.liveProgress * 100).toInt()}%)');
    }
    print('==========================\n');
  }
}