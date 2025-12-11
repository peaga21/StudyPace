import '../entities/goal_entity.dart';
import '../../data/repositories/goal_repository.dart';

class CreateGoalUseCase {
  final GoalRepository repository;
  
  CreateGoalUseCase(this.repository);
  
  Future<GoalEntity> call(GoalEntity goal) async {
    return await repository.createGoal(goal);
  }
}