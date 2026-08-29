enum InterventionCategory {
  breathwork,
  relaxation,
  sleep_audio,
  cognitive,
  morning_activation,
  unknown
}

enum EvidenceLevel {
  strong,
  moderate,
  supportive,
  experimental,
  unknown
}

class Intervention {
  final String id;
  final String name;
  final InterventionCategory category;
  final String intendedUse;
  final EvidenceLevel evidenceLevel;
  final String supportingResearch;
  final String contraindications;
  final int recommendedDurationMin;
  final int recommendedDurationMax;
  final List<String> recommendedContext;
  final String audioType;
  final Map<String, dynamic> personalizationParameters;
  final bool isExperimental;

  Intervention({
    required this.id,
    required this.name,
    required this.category,
    required this.intendedUse,
    required this.evidenceLevel,
    required this.supportingResearch,
    required this.contraindications,
    required this.recommendedDurationMin,
    required this.recommendedDurationMax,
    required this.recommendedContext,
    required this.audioType,
    required this.personalizationParameters,
    required this.isExperimental,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      id: json['id'] as String,
      name: json['name'] as String,
      category: InterventionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => InterventionCategory.unknown,
      ),
      intendedUse: json['intendedUse'] as String,
      evidenceLevel: EvidenceLevel.values.firstWhere(
        (e) => e.name == json['evidenceLevel'],
        orElse: () => EvidenceLevel.unknown,
      ),
      supportingResearch: json['supportingResearch'] as String? ?? '',
      contraindications: json['contraindications'] as String? ?? '',
      recommendedDurationMin: json['recommendedDurationMin'] as int? ?? 1,
      recommendedDurationMax: json['recommendedDurationMax'] as int? ?? 60,
      recommendedContext: List<String>.from(json['recommendedContext'] ?? []),
      audioType: json['audioType'] as String? ?? '',
      personalizationParameters: json['personalizationParameters'] as Map<String, dynamic>? ?? {},
      isExperimental: json['isExperimental'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'intendedUse': intendedUse,
      'evidenceLevel': evidenceLevel.name,
      'supportingResearch': supportingResearch,
      'contraindications': contraindications,
      'recommendedDurationMin': recommendedDurationMin,
      'recommendedDurationMax': recommendedDurationMax,
      'recommendedContext': recommendedContext,
      'audioType': audioType,
      'personalizationParameters': personalizationParameters,
      'isExperimental': isExperimental,
    };
  }
}
