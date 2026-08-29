import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/night_plan.dart';
import 'package:neend_companion/models/morning_plan.dart';

class PlanRepository {
  static const String _boxName = 'plans';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<NightPlan?> getActiveNightPlan() async {
    try {
      final box = await _getBox();
      final data = box.get('night_plan');
      if (data != null) {
        return NightPlan.fromJson(jsonDecode(data.toString()));
      }
    } catch (e) {}
    return null;
  }

  Future<void> saveNightPlan(NightPlan plan) async {
    try {
      final box = await _getBox();
      await box.put('night_plan', jsonEncode(plan.toJson()));
    } catch (e) {}
  }

  Future<MorningPlan?> getActiveMorningPlan() async {
    try {
      final box = await _getBox();
      final data = box.get('morning_plan');
      if (data != null) {
        return MorningPlan.fromJson(jsonDecode(data.toString()));
      }
    } catch (e) {}
    return null;
  }

  Future<void> saveMorningPlan(MorningPlan plan) async {
    try {
      final box = await _getBox();
      await box.put('morning_plan', jsonEncode(plan.toJson()));
    } catch (e) {}
  }
}
