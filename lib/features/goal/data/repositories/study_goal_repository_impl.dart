import 'package:shared_preferences/shared_preferences.dart';
import 'package:studypace/features/goal/data/models/study_goal.dart';
import 'package:studypace/features/goal/data/repositories/study_goal_repository.dart';
import 'package:studypace/features/goal/domain/entities/goal_entity.dart';
import 'dart:convert';

class StudyGoalRepositoryImpl implements StudyGoalRepository {
  final SharedPreferences prefs;
  final String _goalsKey = 'study_goals';
  
  StudyGoalRepositoryImpl({required this.prefs}); // Fix: Changed to StudyGoal
  
  @override
  Future<List<GoalEntity>> getAllGoals() async {
    try {
      final jsonString = prefs.getString(_goalsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => StudyGoal.fromMap(json)).toList().cast<GoalEntity>();
    } catch (e) {
      print('Erro ao carregar metas: $e');
      return [];
    }
  }
  
  @override
  Future<GoalEntity?> getGoalById(String id) async {
    final goals = await getAllGoals();
    try {
      return goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> saveGoal(GoalEntity goalEntity) async {
    final goals = await getAllGoals();
    final index = goals.indexWhere((g) => g.id == goalEntity.id);
    
    if (index >= 0) {
      goals[index] = goalEntity;
    } else {
      goals.add(goalEntity);
    }
    
    await _saveAllGoals(goals.cast<StudyGoal>());
  }
  
  @override
  Future<void> deleteGoal(String id) async {
    final goals = await getAllGoals();
    goals.removeWhere((goal) => goal.id == id);
    await _saveAllGoals(goals.cast<StudyGoal>());
  }
  
  @override
  Future<void> updateProgress(String id, int minutesCompleted) async {
    final goal = await getGoalById(id);
    if (goal != null) {
      // GoalEntity does not have copyWith, so we create a new one
      final updatedGoal = GoalEntity(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        deadline: goal.deadline,
        progress: goal.progress, // This will be recalculated in the provider
        createdAt: goal.createdAt,
        targetMinutes: goal.targetMinutes,
        completedMinutes: goal.completedMinutes + minutesCompleted,
        isCompleted: (goal.completedMinutes + minutesCompleted) >= goal.targetMinutes,
      );
      await saveGoal(updatedGoal);
    }
  }
  
  Future<void> _saveAllGoals(List<StudyGoal> goals) async {
    final jsonList = goals.map((goal) => goal.toMap()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_goalsKey, jsonString);
  }
}