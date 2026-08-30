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

  /// Maps the label shown during onboarding onto the stored enum value.
  ExperienceStyle get experienceStyle {
    switch (selectedStyle?.toLowerCase()) {
      case 'warm':
        return ExperienceStyle.warm;
      case 'minimal':
        return ExperienceStyle.minimal;
      case 'motivating':
        return ExperienceStyle.motivating;
      case 'calm':
        return ExperienceStyle.calm;
      default:
        return ExperienceStyle.calm;
    }
  }

  Future<void> saveProfile() async {
    final now = DateTime.now();
    final existing = await _userRepository.getProfile();

    final profile = UserProfile(
      id: existing?.id ?? 'default_user',
      displayName: existing?.displayName ?? 'User',
      goals: selectedGoals.toList(),
      sleepPreference: existing?.sleepPreference ?? SleepPreference.flexible,
      experienceStyle: experienceStyle,
      usualSleepTime: sleepTime,
      usualWakeTime: wakeTime,
      voicePreference: existing?.voicePreference ?? VoicePreference.neutral_ai,
      onboardingCompleted: true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _userRepository.saveProfile(profile);
  }
}
