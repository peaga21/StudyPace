import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> getGoals();
  Future<GoalEntity> getGoalById(String id);
  Future<GoalEntity> createGoal(GoalEntity goal);
  Future<GoalEntity> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String id);
}