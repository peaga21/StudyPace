import '../entities/goal_entity.dart';
import '../repositories/goal_repository.dart';

class UpdateGoalUseCase {
  final GoalRepository repository;
  
  UpdateGoalUseCase(this.repository);
  
  Future<GoalEntity> call(GoalEntity goal) async {
    return await repository.updateGoal(goal);
  }
}