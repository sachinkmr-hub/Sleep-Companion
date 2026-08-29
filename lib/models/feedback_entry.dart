enum FeedbackType {
  night,
  morning,
  unknown
}

class FeedbackEntry {
  final String id;
  final FeedbackType type;
  final String rating;
  final List<String> interventionIds;
  final int? sleepDurationMinutes;
  final String? notes;
  final DateTime createdAt;

  FeedbackEntry({
    required this.id,
    required this.type,
    required this.rating,
    required this.interventionIds,
    this.sleepDurationMinutes,
    this.notes,
    required this.createdAt,
  });

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      id: json['id'] as String,
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.unknown,
      ),
      rating: json['rating'] as String,
      interventionIds: List<String>.from(json['interventionIds'] ?? []),
      sleepDurationMinutes: json['sleepDurationMinutes'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'rating': rating,
      'interventionIds': interventionIds,
      'sleepDurationMinutes': sleepDurationMinutes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
