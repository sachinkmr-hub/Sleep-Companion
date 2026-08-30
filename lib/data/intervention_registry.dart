import 'package:neend_companion/models/intervention.dart';

/// Static catalogue of the evidence-informed interventions the app can build
/// night and morning plans from.
///
/// The entries are descriptive only — they document what each technique is
/// intended for and how well supported it is. They are not medical advice.
class InterventionRegistry {
  const InterventionRegistry._();

  static final List<Intervention> _interventions = [
    Intervention(
      id: 'INT_BREATH_478',
      name: '4-7-8 Breathing',
      category: InterventionCategory.breathwork,
      intendedUse: 'Calm an activated nervous system before sleep',
      evidenceLevel: EvidenceLevel.moderate,
      supportingResearch:
          'Relaxation response via extended exhalation activates vagus nerve',
      contraindications: 'Stop if you feel lightheaded or short of breath',
      recommendedDurationMin: 5,
      recommendedDurationMax: 8,
      recommendedContext: const [
        'anxiety',
        'racing thoughts',
        'stress',
      ],
      audioType: 'guided_breathing',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_BREATH_BOX',
      name: 'Box Breathing 4-4-4-4',
      category: InterventionCategory.breathwork,
      intendedUse: 'Reset focus and steady the breath',
      evidenceLevel: EvidenceLevel.moderate,
      supportingResearch:
          'Evenly paced breathing supports autonomic balance and focus',
      contraindications: 'Stop if you feel lightheaded or short of breath',
      recommendedDurationMin: 4,
      recommendedDurationMax: 6,
      recommendedContext: const ['focus', 'nervous system reset'],
      audioType: 'guided_breathing',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_PMR',
      name: 'Progressive Muscle Relaxation',
      category: InterventionCategory.relaxation,
      intendedUse: 'Release physical tension held in the body',
      evidenceLevel: EvidenceLevel.strong,
      supportingResearch:
          'Sequential tense-and-release lowers muscular and subjective tension',
      contraindications: 'Skip muscle groups that are injured or painful',
      recommendedDurationMin: 10,
      recommendedDurationMax: 15,
      recommendedContext: const ['physical tension', 'body stress', 'stress'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_BODY_SCAN',
      name: 'Body Scan',
      category: InterventionCategory.relaxation,
      intendedUse: 'Shift attention away from thoughts and into the body',
      evidenceLevel: EvidenceLevel.moderate,
      supportingResearch:
          'Attention-to-body practices reduce cognitive arousal at bedtime',
      contraindications: '',
      recommendedDurationMin: 10,
      recommendedDurationMax: 15,
      recommendedContext: const ['general stress', 'body awareness', 'stress'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_GUIDED_IMAGERY',
      name: 'Guided Imagery',
      category: InterventionCategory.relaxation,
      intendedUse: 'Occupy the mind with a calming scene',
      evidenceLevel: EvidenceLevel.moderate,
      supportingResearch:
          'Imagery gives the mind a low-arousal focus during wind-down',
      contraindications: '',
      recommendedDurationMin: 8,
      recommendedDurationMax: 12,
      recommendedContext: const ['calming visualization', 'stress'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_THOUGHT_DUMP',
      name: 'Worry Brain Dump',
      category: InterventionCategory.cognitive,
      intendedUse: 'Offload tomorrow\'s open loops before sleep',
      evidenceLevel: EvidenceLevel.moderate,
      supportingResearch:
          'Writing down pending tasks shortens self-reported sleep onset',
      contraindications: '',
      recommendedDurationMin: 5,
      recommendedDurationMax: 5,
      recommendedContext: const [
        'high stressor load',
        'task overload',
        'stress',
        'racing thoughts',
      ],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_RAIN',
      name: 'Gentle Rain Soundscape',
      category: InterventionCategory.sleepAudio,
      intendedUse: 'Mask background noise while falling asleep',
      evidenceLevel: EvidenceLevel.supportive,
      supportingResearch:
          'Steady broadband sound masks disruptive environmental noise',
      contraindications: 'Keep the volume low and comfortable',
      recommendedDurationMin: 15,
      recommendedDurationMax: 60,
      recommendedContext: const ['sleep onset', 'noise masking'],
      audioType: 'soundscape',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_BROWN',
      name: 'Brown Noise',
      category: InterventionCategory.sleepAudio,
      intendedUse: 'Mask noise with a low-frequency weighted sound',
      evidenceLevel: EvidenceLevel.supportive,
      supportingResearch:
          'Low-frequency weighted noise is often rated as less intrusive',
      contraindications: 'Keep the volume low and comfortable',
      recommendedDurationMin: 15,
      recommendedDurationMax: 60,
      recommendedContext: const ['noise masking', 'deep focus', 'sleep onset'],
      audioType: 'soundscape',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_NATURE',
      name: 'Nature Sounds',
      category: InterventionCategory.sleepAudio,
      intendedUse: 'Wind down with a calming natural soundscape',
      evidenceLevel: EvidenceLevel.supportive,
      supportingResearch:
          'Nature soundscapes are commonly rated as relaxing at bedtime',
      contraindications: 'Keep the volume low and comfortable',
      recommendedDurationMin: 15,
      recommendedDurationMax: 60,
      recommendedContext: const ['relaxation', 'calm', 'sleep onset'],
      audioType: 'soundscape',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_PIANO',
      name: 'Soft Piano',
      category: InterventionCategory.sleepAudio,
      intendedUse: 'Wind down with slow instrumental music',
      evidenceLevel: EvidenceLevel.supportive,
      supportingResearch:
          'Slow-tempo instrumental music is associated with easier wind-down',
      contraindications: 'Keep the volume low and comfortable',
      recommendedDurationMin: 15,
      recommendedDurationMax: 30,
      recommendedContext: const ['calming instrumental', 'sleep onset'],
      audioType: 'soundscape',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_LIGHT',
      name: 'Morning Light Exposure',
      category: InterventionCategory.morningActivation,
      intendedUse: 'Anchor the body clock shortly after waking',
      evidenceLevel: EvidenceLevel.strong,
      supportingResearch:
          'Morning light exposure supports circadian entrainment',
      contraindications: 'Never look directly at the sun',
      recommendedDurationMin: 10,
      recommendedDurationMax: 10,
      recommendedContext: const ['cortisol awakening response', 'wake_up'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_HYDRATE',
      name: 'Morning Hydration',
      category: InterventionCategory.morningActivation,
      intendedUse: 'Rehydrate after the overnight fast',
      evidenceLevel: EvidenceLevel.supportive,
      supportingResearch: 'Rehydrating on waking helps offset overnight losses',
      contraindications: '',
      recommendedDurationMin: 3,
      recommendedDurationMax: 3,
      recommendedContext: const ['metabolism activation', 'wake_up'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_STRETCH',
      name: 'Morning Stretch',
      category: InterventionCategory.morningActivation,
      intendedUse: 'Ease stiffness and get moving',
      evidenceLevel: EvidenceLevel.supportive,
      supportingResearch: 'Light movement raises alertness after waking',
      contraindications: 'Stay within a comfortable range of motion',
      recommendedDurationMin: 5,
      recommendedDurationMax: 5,
      recommendedContext: const ['physical activation', 'wake_up'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_PRIMING',
      name: 'Goal Visualization',
      category: InterventionCategory.morningActivation,
      intendedUse: 'Set an intention for the day ahead',
      evidenceLevel: EvidenceLevel.experimental,
      supportingResearch:
          'Intention setting is popular but only weakly evidenced for sleep',
      contraindications: '',
      recommendedDurationMin: 5,
      recommendedDurationMax: 5,
      recommendedContext: const ['intention setting', 'wake_up'],
      audioType: 'guided_voice',
      personalizationParameters: const {},
      isExperimental: true,
    ),
  ];

  static const List<InterventionCategory> _nightCategories = [
    InterventionCategory.breathwork,
    InterventionCategory.relaxation,
    InterventionCategory.cognitive,
    InterventionCategory.sleepAudio,
  ];

  static List<Intervention> getAll() => List.unmodifiable(_interventions);

  static Intervention? getById(String id) {
    for (final intervention in _interventions) {
      if (intervention.id == id) return intervention;
    }
    return null;
  }

  static List<Intervention> getByCategory(InterventionCategory category) {
    return _interventions
        .where((element) => element.category == category)
        .toList();
  }

  static List<Intervention> getNightInterventions() {
    return _interventions
        .where((element) => _nightCategories.contains(element.category))
        .toList();
  }

  static List<Intervention> getMorningInterventions() {
    return getByCategory(InterventionCategory.morningActivation);
  }
}
