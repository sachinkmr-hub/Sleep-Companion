import 'package:neend_companion/models/extracted_context.dart';

class CheckIn {
  final String id;
  final String rawInput;
  final ExtractedContext? extractedContext;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.rawInput,
    this.extractedContext,
    required this.createdAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      rawInput: json['rawInput'] as String,
      extractedContext: json['extractedContext'] != null
          ? ExtractedContext.fromJson(json['extractedContext'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawInput': rawInput,
      'extractedContext': extractedContext?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
