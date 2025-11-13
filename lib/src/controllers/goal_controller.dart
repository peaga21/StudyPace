import 'package:flutter/material.dart';
import '../models/study_goal.dart';
import '../services/goal_service.dart';

class GoalController with ChangeNotifier {
  final GoalService _goalService;
  
  List<StudyGoal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalController(this._goalService);

  // Getters
  List<StudyGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar metas
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _goals = await _goalService.getGoalsSortedByDate();
      print('✅ Metas carregadas: ${_goals.length}'); // Debug
    } catch (e) {
      _error = 'Erro ao carregar metas: $e';
      print('❌ Erro ao carregar metas: $e'); // Debug
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar nova meta
  Future<bool> createGoal({
    required String title,
    required String description,
    required int targetMinutes,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final newGoal = await _goalService.createGoal(
        title: title,
        description: description,
        targetMinutes: targetMinutes,
      );
      _goals.insert(0, newGoal);
      _error = null;
      
      // FORÇAR SALVAMENTO
      await loadGoals(); // Recarregar para garantir persistência
      
      return true;
    } catch (e) {
      _error = 'Erro ao criar meta: $e';
      print('❌ Erro ao criar meta: $e'); // Debug
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar progresso - CORRIGIDO
  Future<void> updateGoalProgress(String goalId, int minutesCompleted) async {
    try {
      await _goalService.updateProgress(goalId, minutesCompleted);
      
      // Atualizar lista local
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index >= 0) {
        final updatedGoal = _goals[index].copyWith(
          completedMinutes: minutesCompleted,
          isCompleted: minutesCompleted >= _goals[index].targetMinutes,
        );
        _goals[index] = updatedGoal;
      }
      
      // Recarregar para garantir persistência
      await loadGoals();
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar progresso: $e';
      print('❌ Erro ao atualizar progresso: $e'); // Debug
      notifyListeners();
    }
  }

  // Deletar meta
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalService.deleteGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar meta: $e';
      notifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // NOVO: Debug - ver metas salvas
  void debugPrintGoals() {
    print('📋 Metas atuais:');
    for (final goal in _goals) {
      print(' - ${goal.title}: ${goal.completedMinutes}/${goal.targetMinutes}min (${goal.progress * 100}%)');
    }
  }
}