import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Inicializar o serviço de notificações
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Agendar lembrete para meta específica
  Future<void> scheduleStudyReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'study_reminder_channel',
      'Lembretes de Estudo',
      channelDescription: 'Lembretes para suas metas de estudo',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  // Agendar lembrete diário do Pomodoro
  Future<void> schedulePomodoroReminder(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final scheduledTime = scheduledDate.isBefore(now) 
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Lembretes Pomodoro',
      channelDescription: 'Lembretes para pausas e estudos',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      999, // ID fixo para lembrete Pomodoro
      '🎯 Hora do StudyPace!',
      'Que tal uma sessão de estudo? Lembre-se das pausas do Pomodoro!',
      scheduledTime,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      details,
      androidAllowWhileIdle: true,
    );
  }

  // Agendar lembrete de pausa
  Future<void> scheduleBreakReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'break_reminder_channel',
      'Lembretes de Pausa',
      channelDescription: 'Lembretes para pausas do Pomodoro',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      998,
      '⏰ Hora da Pausa!',
      'Faça uma pausa de 5 minutos antes da próxima sessão',
      tz.TZDateTime.now(tz.local).add(const Duration(minutes: 25)),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      details,
    );
  }

  // Cancelar todos os lembretes
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Cancelar lembrete específico
  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }
}