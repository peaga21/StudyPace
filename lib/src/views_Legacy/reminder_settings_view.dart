import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services_Legacy/notification_service.dart';
import '../services_Legacy/pomodoro_scheduler.dart';
import 'package:studypace/features/goal/presentation/providers/goal_provider.dart';


class ReminderSettingsView extends StatefulWidget {
  const ReminderSettingsView({super.key});

  @override
  State<ReminderSettingsView> createState() => _ReminderSettingsViewState();
}

class _ReminderSettingsViewState extends State<ReminderSettingsView> {
  final NotificationService _notificationService = NotificationService();
  final PomodoroScheduler _pomodoroScheduler = PomodoroScheduler();
  
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _dailyRemindersEnabled = false;
  bool _pomodoroRemindersEnabled = false;
  bool _goalRemindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Carregar configurações salvas (simulação)
    setState(() {
      _dailyRemindersEnabled = true;
      _pomodoroRemindersEnabled = true;
      _goalRemindersEnabled = true;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );
    
    if (picked != null && picked != _dailyReminderTime) {
      setState(() {
        _dailyReminderTime = picked;
      });
      await _updateDailyReminder();
    }
  }

  Future<void> _updateDailyReminder() async {
    if (_dailyRemindersEnabled) {
      await _notificationService.schedulePomodoroReminder(_dailyReminderTime);
    } else {
      await _notificationService.cancelReminder(999);
    }
  }

  Future<void> _scheduleGoalReminders() async {
    final goalProvider = context.read<GoalProvider>();
    final goals = goalProvider.goals.where((goal) => !goal.isCompleted).toList();
    
    int reminderId = 1000;
    
    for (final goal in goals) {
      final pomodoros = _pomodoroScheduler.calculateOptimalPomodoros(goal.targetMinutes);
      
      await _notificationService.scheduleStudyReminder(
        id: reminderId++,
        title: '🎯 ${goal.title}',
        body: 'Meta: ${goal.targetMinutes} minutos • $pomodoros sessões Pomodoro',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)), // Próxima hora
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${goals.length} lembretes agendados!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Lembretes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Lembretes Diários
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lembrete Diário',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch(
                          value: _dailyRemindersEnabled,
                          onChanged: (value) async {
                            setState(() {
                              _dailyRemindersEnabled = value;
                            });
                            await _updateDailyReminder();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_dailyRemindersEnabled) ...[
                      Text(
                        'Horário do lembrete:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          _dailyReminderTime.format(context),
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _selectTime(context),
                        tileColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lembretes Pomodoro
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lembretes Pomodoro',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Lembretes automáticos para pausas',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _pomodoroRemindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _pomodoroRemindersEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lembretes de Metas
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lembretes de Metas',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Lembretes para metas pendentes',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _goalRemindersEnabled,
                          onChanged: (value) {
                            setState(() {
                              _goalRemindersEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_goalRemindersEnabled) ...[
                      const SizedBox(height: 12),
                      Consumer<GoalProvider>(
                        builder: (context, goalProvider, child) {
                          final pendingGoals = goalProvider.goals.where((goal) => !goal.isCompleted).length;
                          
                          return Column(
                            children: [
                              Text(
                                '$pendingGoals metas pendentes',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: pendingGoals > 0 ? _scheduleGoalReminders : null,
                                icon: const Icon(Icons.notifications),
                                label: const Text('Agendar Lembretes'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sugestões Inteligentes
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.purple),
                        const SizedBox(width: 12),
                        Text(
                          'Sugestões Inteligentes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Horários sugeridos para estudo:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pomodoroScheduler
                          .generateSmartTimeSuggestions()
                          .map((time) => Chip(
                                label: Text(time.format(context)),
                                onDeleted: () {
                                  // Agendar para este horário
                                  _notificationService.schedulePomodoroReminder(time);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lembrete agendado para ${time.format(context)}'),
                                    ),
                                  );
                                },
                                deleteIcon: const Icon(Icons.add_alarm, size: 16),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ações Rápidas
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações Rápidas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _notificationService.cancelAllReminders,
                            icon: const Icon(Icons.notifications_off),
                            label: const Text('Cancelar Todos'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _notificationService.initialize();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notificações reinicializadas!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reinicializar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}