import 'package:flutter/material.dart';
import 'notification_service.dart';

class PomodoroScheduler {
  final NotificationService _notificationService = NotificationService();
  
  // Agendar sessão de estudo com lembretes Pomodoro
  Future<void> schedulePomodoroSession({
    required String goalTitle,
    required int sessionId,
    required TimeOfDay startTime,
    required int totalPomodoros,
  }) async {
    final now = TimeOfDay.now();
    final isToday = startTime.hour > now.hour || 
                   (startTime.hour == now.hour && startTime.minute > now.minute);

    DateTime baseDate = DateTime.now();
    if (!isToday) {
      baseDate = baseDate.add(const Duration(days: 1));
    }

    // Agendar lembretes para cada Pomodoro
    for (int i = 0; i < totalPomodoros; i++) {
      final sessionTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        startTime.hour,
        startTime.minute + (i * 30), // 25 min estudo + 5 min pausa
      );

      await _notificationService.scheduleStudyReminder(
        id: sessionId + i,
        title: '🍅 Sessão ${i + 1}/$totalPomodoros',
        body: 'Hora de estudar: $goalTitle',
        scheduledTime: sessionTime,
      );

      // Agendar lembrete de pausa (5 minutos após o início da sessão)
      final breakTime = sessionTime.add(const Duration(minutes: 25));
      await _notificationService.scheduleStudyReminder(
        id: sessionId + i + 1000, // IDs diferentes para pausas
        title: '⏸️ Hora da Pausa!',
        body: 'Descanse 5 minutos antes da próxima sessão',
        scheduledTime: breakTime,
      );
    }
  }

  // Gerar sugestões inteligentes de horários
  List<TimeOfDay> generateSmartTimeSuggestions() {
    final now = TimeOfDay.now();
    final suggestions = <TimeOfDay>[];
    
    // Horários baseados em estudos de produtividade
    final productiveTimes = [
      const TimeOfDay(hour: 8, minute: 0),   // Manhã
      const TimeOfDay(hour: 10, minute: 0),  // Meio da manhã
      const TimeOfDay(hour: 14, minute: 0),  // Tarde
      const TimeOfDay(hour: 16, minute: 0),  // Final da tarde
      const TimeOfDay(hour: 20, minute: 0),  // Noite
    ];

    for (final time in productiveTimes) {
      if (time.hour > now.hour || (time.hour == now.hour && time.minute > now.minute)) {
        suggestions.add(time);
      }
    }

    // Se não há horários hoje, sugere para amanhã nos mesmos horários
    if (suggestions.isEmpty) {
      return productiveTimes;
    }

    return suggestions;
  }

  // Calcular tempo ideal de estudo baseado na meta
  int calculateOptimalPomodoros(int targetMinutes) {
    const pomodoroDuration = 25; // 25 minutos por Pomodoro
    final estimatedPomodoros = (targetMinutes / pomodoroDuration).ceil();
    
    // Limitar a 8 Pomodoros por dia (4 horas)
    return estimatedPomodoros.clamp(1, 8);
  }
}