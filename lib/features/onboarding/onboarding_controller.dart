import 'package:flutter/material.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/data/repositories/user_repository.dart';

class OnboardingController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  Set<String> selectedGoals = {};
  String? selectedStyle;
  String sleepTime = "11:00 PM";
  String wakeTime = "07:00 AM";
  int currentPage = 0;

  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else {
      selectedGoals.add(goal);
    }
    notifyListeners();
  }

  void setStyle(String style) {
    selectedStyle = style;
    notifyListeners();
  }

  void setSleepTime(String time) {
    sleepTime = time;
    notifyListeners();
  }

  void setWakeTime(String time) {
    wakeTime = time;
    notifyListeners();
  }

  void setPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    final profile = UserProfile(
      id: 'default_user',
      displayName: 'User',
      goals: selectedGoals.toList(),
      experienceStyle: selectedStyle ?? 'Calm',
      usualSleepTime: sleepTime,
      usualWakeTime: wakeTime,
      voicePreference: 'Default',
      onboardingCompleted: true,
    );
    await _userRepository.saveProfile(profile);
  }
}
