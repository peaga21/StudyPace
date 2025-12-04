import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource localDataSource;
  
  GoalRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<GoalEntity>> getGoals() async {
    final goals = await localDataSource.getGoals();
    return goals;
  }
  
  @override
  Future<GoalEntity> getGoalById(String id) async {
    final goal = await localDataSource.getGoalById(id);
    return goal;
  }
  
  @override
  Future<GoalEntity> createGoal(GoalEntity goal) async {
    final goalModel = GoalModel.fromEntity(goal);
    await localDataSource.saveGoal(goalModel);
    return goal;
  }
  
  @override
  Future<GoalEntity> updateGoal(GoalEntity goal) async {
    final goalModel = GoalModel.fromEntity(goal);
    await localDataSource.saveGoal(goalModel);
    return goal;
  }
  
  @override
  Future<void> deleteGoal(String id) async {
    await localDataSource.deleteGoal(id);
  }
}