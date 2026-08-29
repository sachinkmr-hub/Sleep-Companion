enum AudioCategory {
  sleep,
  relaxation,
  calming,
  focus,
  morning_energy,
  nature,
  ambient,
  unknown
}

class AudioTrack {
  final String id;
  final String name;
  final AudioCategory category;
  final int intensity;
  final int durationSeconds;
  final List<String> tags;
  final String assetPath;
  final List<String> recommendedContext;
  final bool isLoopable;

  AudioTrack({
    required this.id,
    required this.name,
    required this.category,
    required this.intensity,
    required this.durationSeconds,
    required this.tags,
    required this.assetPath,
    required this.recommendedContext,
    required this.isLoopable,
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      category: AudioCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AudioCategory.unknown,
      ),
      intensity: json['intensity'] as int,
      durationSeconds: json['durationSeconds'] as int,
      tags: List<String>.from(json['tags'] ?? []),
      assetPath: json['assetPath'] as String,
      recommendedContext: List<String>.from(json['recommendedContext'] ?? []),
      isLoopable: json['isLoopable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'intensity': intensity,
      'durationSeconds': durationSeconds,
      'tags': tags,
      'assetPath': assetPath,
      'recommendedContext': recommendedContext,
      'isLoopable': isLoopable,
    };
  }
}
