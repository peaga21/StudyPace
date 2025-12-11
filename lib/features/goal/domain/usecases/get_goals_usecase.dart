import '../entities/goal_entity.dart';
import '../../data/repositories/goal_repository.dart';

class GetGoalsUseCase {
  final GoalRepository repository;
  
  GetGoalsUseCase(this.repository);
  
  Future<List<GoalEntity>> call() async {
    return await repository.getGoals();
  }
}