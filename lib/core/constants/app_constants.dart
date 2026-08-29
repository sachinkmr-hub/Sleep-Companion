class AppConstants {
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationStandard = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Default Durations
  static const Duration defaultAlarmTimeout = Duration(minutes: 10);
  static const Duration defaultSnoozeDuration = Duration(minutes: 9);

  // Hive Boxes
  static const String settingsBox = 'settingsBox';
  static const String userBox = 'userBox';
  static const String sleepDataBox = 'sleepDataBox';

  // Limits
  static const int maxInputLength = 250;
  static const int maxVoiceRecordingDurationSeconds = 60;
}
