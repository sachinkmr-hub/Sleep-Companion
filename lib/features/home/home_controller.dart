import 'package:flutter/material.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/data/repositories/user_repository.dart';
import 'package:neend_companion/data/repositories/checkin_repository.dart';
import 'package:neend_companion/data/repositories/alarm_repository.dart';
import 'package:neend_companion/data/repositories/plan_repository.dart';

class HomeController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final CheckinRepository _checkinRepository = CheckinRepository();
  final AlarmRepository _alarmRepository = AlarmRepository();
  final PlanRepository _planRepository = PlanRepository();
  
  UserProfile? userProfile;
  bool isLoading = true;
  String contextSummary = 'You had a productive day today.';
  String alarmTimeDisplay = "7:00 AM";
  bool hasActivePlan = false;
  String userName = 'there';

  HomeController() {
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    notifyListeners();
    
    userProfile = await _userRepository.getProfile();
    userName = userProfile?.displayName ?? 'there';
    alarmTimeDisplay = userProfile?.usualWakeTime ?? "7:00 AM";

    // In a real app we'd fetch from respective repositories
    // e.g. contextSummary = await _checkinRepository.getLatestSummary();
    
    isLoading = false;
    notifyListeners();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning, $userName';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $userName';
    } else {
      return 'Good evening, $userName';
    }
  }
}
