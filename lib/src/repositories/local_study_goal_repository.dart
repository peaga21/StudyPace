// ignore_for_file: unused_local_variable

import 'package:shared_preferences/shared_preferences.dart';
import 'study_goal_repository.dart';
import '../models/study_goal.dart';

class LocalStudyGoalRepository implements StudyGoalRepository {
  static const String _storageKey = 'study_goals';
  
  @override
  Future<List<StudyGoal>> getAllGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString(_storageKey);
    
    if (goalsJson == null) return [];
    
    try {
      // Simulando desserialização - você pode usar json.decode depois
      final List<dynamic> goalsList = []; // Substituir por json.decode
      return goalsList.map((goalMap) => StudyGoal.fromMap(goalMap)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<StudyGoal?> getGoalById(String id) async {
    final goals = await getAllGoals();
    return goals.firstWhereOrNull((goal) => goal.id == id);
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
      final updatedGoal = goal.copyWith(
        completedMinutes: minutesCompleted,
        isCompleted: minutesCompleted >= goal.targetMinutes,
      );
      await saveGoal(updatedGoal);
    }
  }

  Future<void> _saveAllGoals(List<StudyGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsMapList = goals.map((goal) => goal.toMap()).toList();
    // Simulando serialização - você pode usar json.encode depois
    prefs.setString(_storageKey, 'saved_goals'); // Substituir por json.encode
  }
}

extension on List<StudyGoal> {
  StudyGoal? firstWhereOrNull(bool Function(StudyGoal goal) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}