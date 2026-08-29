class PlanStep {
  final int stepOrder;
  final String title;
  final String interventionId;
  final int durationMinutes;
  final String instructions;
  final String soundscape;

  PlanStep({
    required this.stepOrder,
    required this.title,
    required this.interventionId,
    required this.durationMinutes,
    required this.instructions,
    required this.soundscape,
  });

  factory PlanStep.fromJson(Map<String, dynamic> json) {
    return PlanStep(
      stepOrder: json['stepOrder'] as int,
      title: json['title'] as String,
      interventionId: json['interventionId'] as String,
      durationMinutes: json['durationMinutes'] as int,
      instructions: json['instructions'] as String,
      soundscape: json['soundscape'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepOrder': stepOrder,
      'title': title,
      'interventionId': interventionId,
      'durationMinutes': durationMinutes,
      'instructions': instructions,
      'soundscape': soundscape,
    };
  }
}

class NightPlan {
  final String theme;
  final int estimatedDurationMinutes;
  final String recommendedBedtime;
  final List<PlanStep> steps;
  final String windDownQuote;
  final DateTime createdAt;

  NightPlan({
    required this.theme,
    required this.estimatedDurationMinutes,
    required this.recommendedBedtime,
    required this.steps,
    required this.windDownQuote,
    required this.createdAt,
  });

  factory NightPlan.fromJson(Map<String, dynamic> json) {
    return NightPlan(
      theme: json['theme'] as String,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      recommendedBedtime: json['recommendedBedtime'] as String,
      steps: (json['steps'] as List)
          .map((e) => PlanStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      windDownQuote: json['windDownQuote'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'recommendedBedtime': recommendedBedtime,
      'steps': steps.map((e) => e.toJson()).toList(),
      'windDownQuote': windDownQuote,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
