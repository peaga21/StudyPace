import '../models/goal_model.dart';

abstract class GoalLocalDataSource {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel> getGoalById(String id);
  Future<void> saveGoals(List<GoalModel> goals);
  Future<void> saveGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  Future<void> clearAll();
}