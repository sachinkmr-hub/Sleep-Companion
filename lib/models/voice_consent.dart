class VoiceConsent {
  final String id;
  final String voiceOwnerName;
  final String relationship;
  final bool permissionGranted;
  final DateTime? grantedAt;
  final DateTime? revokedAt;
  final DateTime createdAt;

  VoiceConsent({
    required this.id,
    required this.voiceOwnerName,
    required this.relationship,
    required this.permissionGranted,
    this.grantedAt,
    this.revokedAt,
    required this.createdAt,
  });

  bool get isActive => permissionGranted && revokedAt == null;

  factory VoiceConsent.fromJson(Map<String, dynamic> json) {
    return VoiceConsent(
      id: json['id'] as String,
      voiceOwnerName: json['voiceOwnerName'] as String,
      relationship: json['relationship'] as String,
      permissionGranted: json['permissionGranted'] as bool,
      grantedAt: json['grantedAt'] != null ? DateTime.parse(json['grantedAt'] as String) : null,
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voiceOwnerName': voiceOwnerName,
      'relationship': relationship,
      'permissionGranted': permissionGranted,
      'grantedAt': grantedAt?.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
