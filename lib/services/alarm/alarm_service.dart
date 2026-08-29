import 'dart:developer';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:neend_companion/models/alarm_data.dart';
import 'package:neend_companion/services/alarm/alarm_callback.dart';

class AlarmService {
  Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  Future<void> scheduleAlarm(AlarmData alarm) async {
    if (!alarm.isEnabled) return;
    
    try {
      await AndroidAlarmManager.oneShotAt(
        alarm.scheduledTime,
        alarm.id,
        alarmCallback,
        exact: true,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );
      log('Alarm scheduled for ${alarm.scheduledTime} with id ${alarm.id}');
    } catch (e) {
      log('Error scheduling alarm: $e');
    }
  }

  Future<void> cancelAlarm(int id) async {
    try {
      await AndroidAlarmManager.cancel(id);
      log('Alarm cancelled: $id');
    } catch (e) {
      log('Error cancelling alarm: $e');
    }
  }

  Future<void> updateAlarm(AlarmData alarm) async {
    await cancelAlarm(alarm.id);
    await scheduleAlarm(alarm);
  }

  AlarmData? getNextAlarm() {
    // This would typically query the repository/local database to find the next active alarm
    return null;
  }

  DateTime parseNaturalLanguageTime(String input) {
    input = input.toLowerCase();
    int hour = 7;
    int minute = 0;
    
    // Basic heuristics for natural language
    if (input.contains('5 baje') || input.contains('5 am')) {
      hour = 5;
    } else if (input.contains('6 baje') || input.contains('6 am') || input.contains('subah 6')) {
      hour = 6;
    } else if (input.contains('7 baje') || input.contains('7 am')) {
      hour = 7;
    } else if (input.contains('8 baje') || input.contains('8 am')) {
      hour = 8;
    }
    
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the parsed time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    
    return scheduled;
  }

  DateTime calculateWakeTime(String sleepTimeStr, int desiredHours) {
    final now = DateTime.now();
    // Simplified: Just returning now + desired hours
    return now.add(Duration(hours: desiredHours));
  }
}
