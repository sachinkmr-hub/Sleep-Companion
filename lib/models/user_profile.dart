enum SleepPreference { early_bird, night_owl, flexible, unknown }
enum ExperienceStyle { calm, warm, minimal, motivating, unknown }
enum VoicePreference { own, mom_dad, partner, friend, neutral_ai, unknown }

class UserProfile {
  final String id;
  final String displayName;
  final List<String> goals;
  final SleepPreference sleepPreference;
  final ExperienceStyle experienceStyle;
  final String usualSleepTime;
  final String usualWakeTime;
  final VoicePreference voicePreference;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.goals,
    required this.sleepPreference,
    required this.experienceStyle,
    required this.usualSleepTime,
    required this.usualWakeTime,
    required this.voicePreference,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      goals: List<String>.from(json['goals'] ?? []),
      sleepPreference: SleepPreference.values.firstWhere(
        (e) => e.name == json['sleepPreference'],
        orElse: () => SleepPreference.unknown,
      ),
      experienceStyle: ExperienceStyle.values.firstWhere(
        (e) => e.name == json['experienceStyle'],
        orElse: () => ExperienceStyle.unknown,
      ),
      usualSleepTime: json['usualSleepTime'] as String,
      usualWakeTime: json['usualWakeTime'] as String,
      voicePreference: VoicePreference.values.firstWhere(
        (e) => e.name == json['voicePreference'],
        orElse: () => VoicePreference.unknown,
      ),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'goals': goals,
      'sleepPreference': sleepPreference.name,
      'experienceStyle': experienceStyle.name,
      'usualSleepTime': usualSleepTime,
      'usualWakeTime': usualWakeTime,
      'voicePreference': voicePreference.name,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    List<String>? goals,
    SleepPreference? sleepPreference,
    ExperienceStyle? experienceStyle,
    String? usualSleepTime,
    String? usualWakeTime,
    VoicePreference? voicePreference,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      goals: goals ?? this.goals,
      sleepPreference: sleepPreference ?? this.sleepPreference,
      experienceStyle: experienceStyle ?? this.experienceStyle,
      usualSleepTime: usualSleepTime ?? this.usualSleepTime,
      usualWakeTime: usualWakeTime ?? this.usualWakeTime,
      voicePreference: voicePreference ?? this.voicePreference,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
