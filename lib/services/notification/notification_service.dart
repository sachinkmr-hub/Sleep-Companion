import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neend_companion/models/alarm_data.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );
    
    // Create necessary channels
    final alarmChannel = const AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Used for alarm ringing',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    
    final remindersChannel = const AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Used for bedtime and goal reminders',
      importance: Importance.high,
    );
    
    final audioChannel = const AndroidNotificationChannel(
      'audio_channel',
      'Media Playback',
      description: 'Used for background audio playback',
      importance: Importance.low,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(remindersChannel);
      await androidPlugin.createNotificationChannel(audioChannel);
    }
  }

  void _onTap(NotificationResponse response) {
    // Navigate to alarm screen or handle action
  }

  @pragma('vm:entry-point')
  static void _onBackgroundTap(NotificationResponse response) {
    // Handle background actions like snooze/dismiss
  }

  Future<void> showAlarmNotification(int id) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      ongoing: true,
      actions: [
        AndroidNotificationAction('DISMISS', 'Dismiss'),
        AndroidNotificationAction('SNOOZE', 'Snooze 5 min'),
      ],
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(
      id,
      'Good Morning!',
      'Time to wake up and start your day.',
      details,
      payload: 'alarm_$id',
    );
  }

  Future<void> showBedtimeReminder(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(
      9999, // Static ID for bedtime reminder
      'Bedtime Reminder',
      message,
      details,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }
}
