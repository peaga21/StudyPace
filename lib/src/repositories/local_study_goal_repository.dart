import 'package:shared_preferences/shared_preferences.dart';
import 'study_goal_repository.dart';
import '../models/study_goal.dart';
import 'dart:convert';

class LocalStudyGoalRepository implements StudyGoalRepository {
  static const String _storageKey = 'study_goals';
  
  @override
  Future<List<StudyGoal>> getAllGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString(_storageKey);
    
    if (goalsJson == null || goalsJson.isEmpty) return [];
    
    try {
      final List<dynamic> goalsList = json.decode(goalsJson);
      return goalsList.map((goalMap) => StudyGoal.fromMap(goalMap)).toList();
    } catch (e) {
      print('Erro ao carregar metas: $e');
      return [];
    }
  }

  @override
  Future<StudyGoal?> getGoalById(String id) async {
    final goals = await getAllGoals();
    try {
      return goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(StudyGoal goal) async {
    final goals = await getAllGoals();
    final existingIndex = goals.indexWhere((g) => g.id == goal.id);
    
    if (existingIndex >= 0) {
      goals[existingIndex] = goal;
    } else {
      goals.add(goal);
    }
    
    await _saveAllGoals(goals);
  }

  @override
  Future<void> deleteGoal(String id) async {
    final goals = await getAllGoals();
    goals.removeWhere((goal) => goal.id == id);
    await _saveAllGoals(goals);
  }

  @override
  Future<void> updateProgress(String id, int minutesCompleted) async {
    final goal = await getGoalById(id);
    if (goal != null) {
      final isCompleted = minutesCompleted >= goal.targetMinutes;
      final updatedGoal = goal.copyWith(
        completedMinutes: minutesCompleted,
        isCompleted: isCompleted,
      );
      await saveGoal(updatedGoal);
    }
  }

  Future<void> _saveAllGoals(List<StudyGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsMapList = goals.map((goal) => goal.toMap()).toList();
    final goalsJson = json.encode(goalsMapList);
    await prefs.setString(_storageKey, goalsJson);
  }

  // NOVO: Limpar todas as metas (para debug)
  Future<void> clearAllGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}