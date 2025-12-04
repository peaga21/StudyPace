import '../entities/goal_entity.dart';
import '../repositories/goal_repository.dart';

class CreateGoalUseCase {
  final GoalRepository repository;
  
  CreateGoalUseCase(this.repository);
  
  Future<GoalEntity> call(GoalEntity goal) async {
    return await repository.createGoal(goal);
  }
}