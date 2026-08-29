class AlarmData {
  final int id;
  final DateTime scheduledTime;
  final String? label;
  final String? tomorrowGoal;
  final bool isEnabled;
  final String? voiceMessageId;
  final int snoozeCount;
  final DateTime createdAt;

  AlarmData({
    required this.id,
    required this.scheduledTime,
    this.label,
    this.tomorrowGoal,
    required this.isEnabled,
    this.voiceMessageId,
    required this.snoozeCount,
    required this.createdAt,
  });

  factory AlarmData.fromJson(Map<String, dynamic> json) {
    return AlarmData(
      id: json['id'] as int,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      label: json['label'] as String?,
      tomorrowGoal: json['tomorrowGoal'] as String?,
      isEnabled: json['isEnabled'] as bool,
      voiceMessageId: json['voiceMessageId'] as String?,
      snoozeCount: json['snoozeCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'label': label,
      'tomorrowGoal': tomorrowGoal,
      'isEnabled': isEnabled,
      'voiceMessageId': voiceMessageId,
      'snoozeCount': snoozeCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AlarmData copyWith({
    int? id,
    DateTime? scheduledTime,
    String? label,
    String? tomorrowGoal,
    bool? isEnabled,
    String? voiceMessageId,
    int? snoozeCount,
    DateTime? createdAt,
  }) {
    return AlarmData(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      label: label ?? this.label,
      tomorrowGoal: tomorrowGoal ?? this.tomorrowGoal,
      isEnabled: isEnabled ?? this.isEnabled,
      voiceMessageId: voiceMessageId ?? this.voiceMessageId,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
