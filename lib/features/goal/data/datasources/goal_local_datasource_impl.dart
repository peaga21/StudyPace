import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final SharedPreferences _prefs;
  static const String _goalsKey = 'study_goals';

  GoalLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<GoalModel>> getGoals() async {
    try {
      final jsonString = _prefs.getString(_goalsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => GoalModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<GoalModel> getGoalById(String id) async {
    final goals = await getGoals();
    return goals.firstWhere((goal) => goal.id == id);
  }

  @override
  Future<void> saveGoals(List<GoalModel> goals) async {
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_goalsKey, jsonString);
  }

  @override
  Future<void> saveGoal(GoalModel goal) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      goals[index] = goal;
    } else {
      goals.add(goal);
    }
    await saveGoals(goals);
  }

  @override
  Future<void> deleteGoal(String id) async {
    final goals = await getGoals();
    goals.removeWhere((goal) => goal.id == id);
    await saveGoals(goals);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_goalsKey);
  }
}