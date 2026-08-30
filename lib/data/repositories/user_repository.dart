import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/user_profile.dart';

class UserRepository {
  /// Also opened by the splash screen and read by the router's redirect.
  static const String boxName = 'user_profile';
  static const String _profileKey = 'profile';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<UserProfile?> getProfile() async {
    try {
      final box = await _getBox();
      final String? data = box.get(_profileKey);
      if (data != null) {
        return UserProfile.fromJson(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('Error getting profile: $e');
    }
    return null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      final box = await _getBox();
      await box.put(_profileKey, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  /// Whether a completed profile is already stored.
  ///
  /// Synchronous so GoRouter's redirect can call it. It reads the very record
  /// [saveProfile] writes, so the stored profile stays the single source of
  /// truth for onboarding state and the two cannot drift apart.
  static bool isOnboardedSync() {
    try {
      if (!Hive.isBoxOpen(boxName)) return false;
      final raw = Hive.box(boxName).get(_profileKey);
      if (raw is! String) return false;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['onboardingCompleted'] == true;
    } catch (e) {
      debugPrint('Error reading onboarding state: $e');
      return false;
    }
  }

  Future<void> deleteProfile() async {
    try {
      final box = await _getBox();
      await box.delete(_profileKey);
    } catch (e) {
      debugPrint('Error deleting profile: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing profile box: $e');
    }
  }
}
