class MorningStep {
  final int stepOrder;
  final String title;
  final String interventionId;
  final int durationMinutes;
  final String instructions;

  MorningStep({
    required this.stepOrder,
    required this.title,
    required this.interventionId,
    required this.durationMinutes,
    required this.instructions,
  });

  factory MorningStep.fromJson(Map<String, dynamic> json) {
    return MorningStep(
      stepOrder: json['stepOrder'] as int,
      title: json['title'] as String,
      interventionId: json['interventionId'] as String,
      durationMinutes: json['durationMinutes'] as int,
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepOrder': stepOrder,
      'title': title,
      'interventionId': interventionId,
      'durationMinutes': durationMinutes,
      'instructions': instructions,
    };
  }
}

class MorningPlan {
  final String wakeTime;
  final String theme;
  final List<MorningStep> steps;
  final String affirmation;
  final DateTime createdAt;

  MorningPlan({
    required this.wakeTime,
    required this.theme,
    required this.steps,
    required this.affirmation,
    required this.createdAt,
  });

  factory MorningPlan.fromJson(Map<String, dynamic> json) {
    return MorningPlan(
      wakeTime: json['wakeTime'] as String,
      theme: json['theme'] as String,
      steps: (json['steps'] as List)
          .map((e) => MorningStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      affirmation: json['affirmation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wakeTime': wakeTime,
      'theme': theme,
      'steps': steps.map((e) => e.toJson()).toList(),
      'affirmation': affirmation,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
