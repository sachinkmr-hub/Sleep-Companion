import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/user_profile.dart';

class UserRepository {
  static const String _boxName = 'user_profile';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<UserProfile?> getProfile() async {
    try {
      final box = await _getBox();
      final String? data = box.get('profile');
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
      await box.put('profile', jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }
}
