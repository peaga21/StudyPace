// lib/features/goal/domain/usecases/delete_goal_usecase.dart
import '../../data/repositories/goal_repository.dart';

class DeleteGoalUseCase {
  final GoalRepository repository;
  
  DeleteGoalUseCase(this.repository);
  
  Future<void> call(String goalId) async {
    return await repository.deleteGoal(goalId);
  }
}