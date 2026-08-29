import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/check_in.dart';

class CheckinRepository {
  static const String _boxName = 'checkins';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<CheckIn>> getCheckins() async {
    try {
      final box = await _getBox();
      final List<dynamic> data = box.values.toList();
      return data.map((e) => CheckIn.fromJson(jsonDecode(e.toString()))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCheckin(CheckIn checkin) async {
    try {
      final box = await _getBox();
      await box.put(checkin.id, jsonEncode(checkin.toJson()));
    } catch (e) {}
  }
}
