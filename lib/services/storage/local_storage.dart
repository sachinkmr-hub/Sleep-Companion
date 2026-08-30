import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/models/check_in.dart';
import 'package:neend_companion/models/feedback_entry.dart';
import 'package:neend_companion/models/alarm_data.dart';

class LocalStorageService {
  static const String _userBox = 'user_box';
  static const String _checkInBox = 'check_in_box';
  static const String _feedbackBox = 'feedback_box';
  static const String _alarmBox = 'alarm_box';

  Future<void> init() async {
    await Hive.openBox(_userBox);
    await Hive.openBox(_checkInBox);
    await Hive.openBox(_feedbackBox);
    await Hive.openBox(_alarmBox);
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    final box = Hive.box(_userBox);
    await box.put('profile', jsonEncode(profile.toJson()));
  }

  UserProfile? getUserProfile() {
    final box = Hive.box(_userBox);
    final data = box.get('profile');
    if (data != null) {
      return UserProfile.fromJson(jsonDecode(data as String));
    }
    return null;
  }

  // Check-Ins
  Future<void> saveCheckIn(CheckIn checkIn) async {
    final box = Hive.box(_checkInBox);
    await box.put(checkIn.id, jsonEncode(checkIn.toJson()));
  }

  List<CheckIn> getAllCheckIns() {
    final box = Hive.box(_checkInBox);
    return box.values.map((e) => CheckIn.fromJson(jsonDecode(e as String))).toList();
  }

  // Feedback Entries
  Future<void> saveFeedbackEntry(FeedbackEntry entry) async {
    final box = Hive.box(_feedbackBox);
    await box.put(entry.id, jsonEncode(entry.toJson()));
  }

  List<FeedbackEntry> getAllFeedbackEntries() {
    final box = Hive.box(_feedbackBox);
    return box.values.map((e) => FeedbackEntry.fromJson(jsonDecode(e as String))).toList();
  }

  // Alarms
  Future<void> saveAlarm(AlarmData alarm) async {
    final box = Hive.box(_alarmBox);
    await box.put(alarm.id.toString(), jsonEncode(alarm.toJson()));
  }

  List<AlarmData> getAllAlarms() {
    final box = Hive.box(_alarmBox);
    return box.values.map((e) => AlarmData.fromJson(jsonDecode(e as String))).toList();
  }
  
  Future<void> deleteAlarm(int id) async {
    final box = Hive.box(_alarmBox);
    await box.delete(id.toString());
  }

  Future<void> clearAllData() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_checkInBox).clear();
    await Hive.box(_feedbackBox).clear();
    await Hive.box(_alarmBox).clear();
  }
}
