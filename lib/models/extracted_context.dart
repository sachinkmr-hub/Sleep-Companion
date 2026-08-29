class ExtractedContext {
  final String moodContext;
  final List<String> stressors;
  final List<String> tomorrowGoals;
  final String? wakeTime;
  final String sleepPreference;
  final String energyLevel;
  final String desiredExperience;
  final String languageDetected;

  ExtractedContext({
    required this.moodContext,
    required this.stressors,
    required this.tomorrowGoals,
    this.wakeTime,
    required this.sleepPreference,
    required this.energyLevel,
    required this.desiredExperience,
    required this.languageDetected,
  });

  factory ExtractedContext.fromJson(Map<String, dynamic> json) {
    return ExtractedContext(
      moodContext: json['moodContext'] as String? ?? '',
      stressors: List<String>.from(json['stressors'] ?? []),
      tomorrowGoals: List<String>.from(json['tomorrowGoals'] ?? []),
      wakeTime: json['wakeTime'] as String?,
      sleepPreference: json['sleepPreference'] as String? ?? '',
      energyLevel: json['energyLevel'] as String? ?? '',
      desiredExperience: json['desiredExperience'] as String? ?? '',
      languageDetected: json['languageDetected'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moodContext': moodContext,
      'stressors': stressors,
      'tomorrowGoals': tomorrowGoals,
      'wakeTime': wakeTime,
      'sleepPreference': sleepPreference,
      'energyLevel': energyLevel,
      'desiredExperience': desiredExperience,
      'languageDetected': languageDetected,
    };
  }
}
