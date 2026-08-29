import 'package:intl/intl.dart';

/// Date and time utilities for the Neend Companion.
class AppDateUtils {
  AppDateUtils._();

  /// Get a time-appropriate greeting.
  static String getGreeting(String? userName) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
    } else {
      greeting = 'Good night';
    }

    if (userName != null && userName.isNotEmpty) {
      return '$greeting, $userName';
    }
    return greeting;
  }

  /// Determine if it's "night mode" time (after 8 PM or before 6 AM).
  static bool isNightTime() {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }

  /// Determine if it's "morning mode" time (6 AM to 11 AM).
  static bool isMorningTime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 11;
  }

  /// Format a DateTime to "HH:MM" 24-hour string.
  static String formatTime24(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format a DateTime to "h:mm a" 12-hour string.
  static String formatTime12(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Parse "HH:MM" string to today's DateTime.
  /// If the time has already passed today, returns tomorrow's DateTime.
  static DateTime parseTimeToNextOccurrence(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeStr. Expected HH:MM');
    }

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();

    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Calculate recommended bedtime to get desired sleep hours before wake time.
  static String calculateBedtime(String wakeTimeStr, {double sleepHours = 7.5}) {
    final wakeParts = wakeTimeStr.split(':');
    final wakeHour = int.parse(wakeParts[0]);
    final wakeMinute = int.parse(wakeParts[1]);

    final sleepMinutes = (sleepHours * 60).round();
    final wakeMinutesSinceMidnight = wakeHour * 60 + wakeMinute;
    var bedtimeMinutes = wakeMinutesSinceMidnight - sleepMinutes;

    // Handle wrapping past midnight
    if (bedtimeMinutes < 0) {
      bedtimeMinutes += 24 * 60;
    }

    final bedHour = bedtimeMinutes ~/ 60;
    final bedMinute = bedtimeMinutes % 60;

    return '${bedHour.toString().padLeft(2, '0')}:${bedMinute.toString().padLeft(2, '0')}';
  }

  /// Format duration in minutes to human-readable string.
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  /// Get relative date string (Today, Yesterday, date).
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get time until a scheduled DateTime, as a human-readable string.
  static String timeUntil(DateTime scheduledTime) {
    final now = DateTime.now();
    final diff = scheduledTime.difference(now);

    if (diff.isNegative) return 'now';

    if (diff.inHours > 0) {
      final minutes = diff.inMinutes % 60;
      if (minutes > 0) {
        return '${diff.inHours}h ${minutes}m';
      }
      return '${diff.inHours}h';
    }

    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min';
    }

    return 'less than a minute';
  }
}
