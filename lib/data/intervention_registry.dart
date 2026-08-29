class Intervention {
  final String id;
  final String title;
  final String category;
  final String evidenceLevel;
  final String durationRange;
  final String context;
  final String? researchNotes;
  final bool isExperimental;

  const Intervention({
    required this.id,
    required this.title,
    required this.category,
    required this.evidenceLevel,
    required this.durationRange,
    required this.context,
    this.researchNotes,
    this.isExperimental = false,
  });
}

class InterventionRegistry {
  static const List<Intervention> _interventions = [
    Intervention(
      id: 'INT_BREATH_478',
      title: '4-7-8 Breathing',
      category: 'breathwork',
      evidenceLevel: 'moderate',
      durationRange: '5-8 min',
      context: 'anxiety, racing thoughts, stress',
      researchNotes: 'Relaxation response via extended exhalation activates vagus nerve',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_BREATH_BOX',
      title: 'Box Breathing 4-4-4-4',
      category: 'breathwork',
      evidenceLevel: 'moderate',
      durationRange: '4-6 min',
      context: 'focus, nervous system reset',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_PMR',
      title: 'Progressive Muscle Relaxation',
      category: 'relaxation',
      evidenceLevel: 'strong',
      durationRange: '10-15 min',
      context: 'physical tension, body stress',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_BODY_SCAN',
      title: 'Body Scan',
      category: 'relaxation',
      evidenceLevel: 'moderate',
      durationRange: '10-15 min',
      context: 'general stress, body awareness',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_GUIDED_IMAGERY',
      title: 'Guided Imagery',
      category: 'relaxation',
      evidenceLevel: 'moderate',
      durationRange: '8-12 min',
      context: 'calming visualization',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_THOUGHT_DUMP',
      title: 'Worry Brain Dump',
      category: 'cognitive',
      evidenceLevel: 'moderate',
      durationRange: '5 min',
      context: 'high stressor load, task overload',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_RAIN',
      title: 'Gentle Rain Soundscape',
      category: 'sleep_audio',
      evidenceLevel: 'supportive',
      durationRange: '15-60 min',
      context: 'sleep onset, noise masking',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_BROWN',
      title: 'Brown Noise',
      category: 'sleep_audio',
      evidenceLevel: 'supportive',
      durationRange: '15-60 min',
      context: 'noise masking, deep focus',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_NATURE',
      title: 'Nature Sounds',
      category: 'sleep_audio',
      evidenceLevel: 'supportive',
      durationRange: '15-60 min',
      context: 'relaxation, calm',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_SOUND_PIANO',
      title: 'Soft Piano',
      category: 'sleep_audio',
      evidenceLevel: 'supportive',
      durationRange: '15-30 min',
      context: 'calming instrumental',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_LIGHT',
      title: 'Morning Light Exposure',
      category: 'morning_activation',
      evidenceLevel: 'strong',
      durationRange: '10 min',
      context: 'cortisol awakening response',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_HYDRATE',
      title: 'Morning Hydration',
      category: 'morning_activation',
      evidenceLevel: 'supportive',
      durationRange: '3 min',
      context: 'metabolism activation',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_STRETCH',
      title: 'Morning Stretch',
      category: 'morning_activation',
      evidenceLevel: 'supportive',
      durationRange: '5 min',
      context: 'physical activation',
      isExperimental: false,
    ),
    Intervention(
      id: 'INT_WAKE_PRIMING',
      title: 'Goal Visualization',
      category: 'morning_activation',
      evidenceLevel: 'experimental',
      durationRange: '5 min',
      context: 'intention setting',
      isExperimental: true,
    ),
  ];

  List<Intervention> getAll() => _interventions;

  Intervention? getById(String id) {
    try {
      return _interventions.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Intervention> getByCategory(String category) {
    return _interventions.where((element) => element.category == category).toList();
  }

  List<Intervention> getNightInterventions() {
    final nightCategories = ['breathwork', 'relaxation', 'cognitive', 'sleep_audio'];
    return _interventions.where((element) => nightCategories.contains(element.category)).toList();
  }

  List<Intervention> getMorningInterventions() {
    return _interventions.where((element) => element.category == 'morning_activation').toList();
  }
}
