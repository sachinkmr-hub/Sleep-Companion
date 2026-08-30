import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/alarm_data.dart';

class AlarmRepository {
  static const String _boxName = 'alarms';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<AlarmData>> getAlarms() async {
    try {
      final box = await _getBox();
      final List<dynamic> data = box.values.toList();
      return data.map((e) => AlarmData.fromJson(jsonDecode(e.toString()))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAlarm(AlarmData alarm) async {
    try {
      final box = await _getBox();
      await box.put(alarm.id, jsonEncode(alarm.toJson()));
    } catch (e) {}
  }

  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {}
  }
}
