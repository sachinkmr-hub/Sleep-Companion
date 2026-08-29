import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/feedback_entry.dart';

class FeedbackRepository {
  static const String _boxName = 'feedback';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<FeedbackEntry>> getFeedback() async {
    try {
      final box = await _getBox();
      final List<dynamic> data = box.values.toList();
      return data.map((e) => FeedbackEntry.fromJson(jsonDecode(e.toString()))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFeedback(FeedbackEntry entry) async {
    try {
      final box = await _getBox();
      await box.put(entry.id, jsonEncode(entry.toJson()));
    } catch (e) {}
  }
}
