import 'dart:math';
import 'package:studypace/features/goal/data/models/study_goal.dart';

class AIInsightService {
  // Simulação de IA - na versão real, você integraria com OpenAI/Gemini
  String generateMotivationalMessage(List<StudyGoal> goals) {
    if (goals.isEmpty) {
      return _getEmptyGoalsMessage();
    }

    final totalGoals = goals.length;
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final completionRate = totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0;
    final totalStudyTime = goals.fold(0, (sum, goal) => sum + goal.completedMinutes);
    
    return _generateInsight(completionRate.toDouble(), totalStudyTime, totalGoals);
  }

  String _getEmptyGoalsMessage() {
    final messages = [
      "🌟 Que tal criar sua primeira meta de estudo? Cada jornada começa com um primeiro passo!",
      "📚 Pronto para transformar seu tempo de estudo? Adicione uma meta e comece agora!",
      "🎯 Suas metas de estudo te esperam! Crie a primeira e veja seu progresso crescer.",
    ];
    return messages[Random().nextInt(messages.length)];
  }

  String _generateInsight(double completionRate, int totalStudyTime, int totalGoals) {
    if (completionRate >= 80) {
      return "🎉 Incrível! Você está mantendo $completionRate% de conclusão. Seu comprometimento é inspirador!";
    } else if (completionRate >= 50) {
      return "💪 Bom trabalho! $completionRate% das metas concluídas. Continue assim, você está no caminho certo!";
    } else if (completionRate > 0) {
      return "🚀 Você começou! $completionRate% é um ótimo início. Foco nas próximas metas!";
    } else {
      return "🎯 Todas as metas esperam por você! Este é o momento perfeito para começar.";
    }
  }

  // Estatísticas detalhadas (simulação de análise de IA)
  Map<String, dynamic> generateDetailedStats(List<StudyGoal> goals) {
    final totalGoals = goals.length;
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final inProgressGoals = goals.where((goal) => !goal.isCompleted && goal.completedMinutes > 0).length;
    final notStartedGoals = goals.where((goal) => goal.completedMinutes == 0).length;
    
    final totalTargetTime = goals.fold(0, (sum, goal) => sum + goal.targetMinutes);
    final totalCompletedTime = goals.fold(0, (sum, goal) => sum + goal.completedMinutes);
    final averageCompletion = totalGoals > 0 ? (totalCompletedTime / totalTargetTime) * 100 : 0;

    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'inProgressGoals': inProgressGoals,
      'notStartedGoals': notStartedGoals,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0,
      'totalTargetTime': totalTargetTime,
      'totalCompletedTime': totalCompletedTime,
      'averageCompletion': averageCompletion,
      'productivityScore': _calculateProductivityScore(goals),
    };
  }

  double _calculateProductivityScore(List<StudyGoal> goals) {
    if (goals.isEmpty) return 0.0;
    
    final completionScore = goals.where((goal) => goal.isCompleted).length / goals.length;
    final progressScore = goals.fold(0.0, (sum, goal) => sum + goal.liveProgress) / goals.length;
    const consistencyBonus = 0.1; // Bônus por ter múltiplas metas
    
    return ((completionScore * 0.6 + progressScore * 0.4) * 100 + consistencyBonus).clamp(0.0, 100.0);
  }
}