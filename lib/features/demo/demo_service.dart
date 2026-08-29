import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/features/demo/demo_data.dart';

class DemoService extends StateNotifier<bool> {
  DemoService() : super(false);

  bool get isDemoMode => state;

  void enableDemo() {
    state = true;
  }

  void disableDemo() {
    state = false;
  }

  // Returns true if demo mode is enabled, false otherwise
  // Allows caller to know if they should use demo methods
  bool shouldUseDemo() => state;

  dynamic getDemoProfile() => DemoData.demoProfile;
  dynamic getDemoContext() => DemoData.demoExtractedContext;
  dynamic getDemoNightPlan() => DemoData.demoNightPlan;
  dynamic getDemoMorningPlan() => DemoData.demoMorningPlan;
  dynamic getDemoAlarm() => DemoData.demoAlarmData;
  dynamic getDemoCheckIn() => DemoData.demoCheckIn;
}

final demoServiceProvider = StateNotifierProvider<DemoService, bool>((ref) {
  return DemoService();
});
