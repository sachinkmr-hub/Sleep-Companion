/// String utilities for the Neend Companion.
class AppStringUtils {
  AppStringUtils._();

  /// Truncate a string to a maximum length with ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize the first letter of a string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Parse a basic natural language time input to "HH:MM" format.
  ///
  /// Handles common patterns:
  /// - "5 baje" → "05:00"
  /// - "7 AM" → "07:00"
  /// - "subah 6 baje" → "06:00"
  /// - "raat 10 baje" → "22:00"
  /// - "11:30 PM" → "23:30"
  /// - "5:00" → "05:00"
  ///
  /// Returns null if parsing fails.
  static String? parseTimeFromText(String input) {
    final text = input.toLowerCase().trim();

    // Try direct HH:MM format first
    final directMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(text);
    if (directMatch != null) {
      var hour = int.parse(directMatch.group(1)!);
      final minute = int.parse(directMatch.group(2)!);

      // Check for AM/PM
      if (text.contains('pm') && hour < 12) hour += 12;
      if (text.contains('am') && hour == 12) hour = 0;

      // Check for Hindi night indicators
      if (_isNightIndicator(text) && hour < 12) hour += 12;

      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }

    // Try "X baje" pattern (Hindi)
    final bajeMatch = RegExp(r'(\d{1,2})\s*baje').firstMatch(text);
    if (bajeMatch != null) {
      var hour = int.parse(bajeMatch.group(1)!);

      // Determine AM/PM from context
      if (_isMorningIndicator(text)) {
        // Morning: keep as-is for hours <= 12
        if (hour == 12) hour = 0;
      } else if (_isNightIndicator(text)) {
        if (hour < 12) hour += 12;
      } else {
        // Default: if hour <= 6, assume morning; if 7-11, check context
        // For alarm context, small numbers are morning
        if (hour >= 1 && hour <= 5) {
          // Early morning, keep as-is
        } else if (hour >= 7 && hour <= 11) {
          // Could be AM or PM, default to AM for alarms
        }
      }

      if (hour >= 0 && hour < 24) {
        return '${hour.toString().padLeft(2, '0')}:00';
      }
    }

    // Try "X AM/PM" pattern
    final ampmMatch = RegExp(r'(\d{1,2})\s*(am|pm)', caseSensitive: false)
        .firstMatch(text);
    if (ampmMatch != null) {
      var hour = int.parse(ampmMatch.group(1)!);
      final period = ampmMatch.group(2)!.toLowerCase();

      if (period == 'pm' && hour < 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;

      if (hour >= 0 && hour < 24) {
        return '${hour.toString().padLeft(2, '0')}:00';
      }
    }

    // Try standalone number (last resort)
    final numberMatch = RegExp(r'(\d{1,2})').firstMatch(text);
    if (numberMatch != null) {
      var hour = int.parse(numberMatch.group(1)!);

      if (hour >= 1 && hour <= 12) {
        // Context-dependent
        if (_isNightIndicator(text) && hour < 12) {
          hour += 12;
        }
        if (hour >= 0 && hour < 24) {
          return '${hour.toString().padLeft(2, '0')}:00';
        }
      }
    }

    return null;
  }

  static bool _isMorningIndicator(String text) {
    return text.contains('subah') ||
        text.contains('morning') ||
        text.contains('savere') ||
        text.contains('pratah') ||
        text.contains('am');
  }

  static bool _isNightIndicator(String text) {
    return text.contains('raat') ||
        text.contains('night') ||
        text.contains('shaam') ||
        text.contains('evening') ||
        text.contains('pm');
  }

  /// Get a user-friendly confirmation for alarm setting.
  static String getAlarmConfirmation(String timeStr, String? goal) {
    // Parse hour for context
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);

    String timeOfDay;
    if (hour >= 4 && hour < 7) {
      timeOfDay = 'early morning';
    } else if (hour >= 7 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'afternoon';
    } else {
      timeOfDay = 'evening';
    }

    // Format for display
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayTime = '$displayHour:${parts[1]} $period';

    String confirmation = 'Done. Alarm set for $displayTime.';

    if (goal != null && goal.isNotEmpty) {
      confirmation += ' $goal is noted for $timeOfDay.';
    }

    return confirmation;
  }

  /// Sanitize user input (remove excessive whitespace, limit length).
  static String sanitizeInput(String input, {int maxLength = 1000}) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .substring(0, input.length > maxLength ? maxLength : input.length);
  }
}
