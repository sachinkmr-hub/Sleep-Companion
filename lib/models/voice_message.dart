class VoiceMessage {
  final String id;
  final String personName;
  final String relationship;
  final String filePath;
  final String prompt;
  final int durationSeconds;
  final String consentId;
  final DateTime createdAt;

  VoiceMessage({
    required this.id,
    required this.personName,
    required this.relationship,
    required this.filePath,
    required this.prompt,
    required this.durationSeconds,
    required this.consentId,
    required this.createdAt,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      id: json['id'] as String,
      personName: json['personName'] as String,
      relationship: json['relationship'] as String,
      filePath: json['filePath'] as String,
      prompt: json['prompt'] as String,
      durationSeconds: json['durationSeconds'] as int,
      consentId: json['consentId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'relationship': relationship,
      'filePath': filePath,
      'prompt': prompt,
      'durationSeconds': durationSeconds,
      'consentId': consentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
