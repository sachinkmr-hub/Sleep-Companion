import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:neend_companion/models/check_in.dart';
import 'package:neend_companion/models/extracted_context.dart';
import 'package:neend_companion/models/night_plan.dart';
import 'package:neend_companion/models/morning_plan.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/data/repositories/checkin_repository.dart';
import 'package:neend_companion/data/repositories/plan_repository.dart';
import 'package:neend_companion/data/repositories/user_repository.dart';
import 'package:neend_companion/services/ai/ai_provider.dart';

final checkinControllerProvider =
    AsyncNotifierProvider<CheckinController, ExtractedContext?>(() {
  return CheckinController();
});

class CheckinController extends AsyncNotifier<ExtractedContext?> {
  final CheckinRepository _checkinRepo = CheckinRepository();
  final PlanRepository _planRepo = PlanRepository();
  final UserRepository _userRepo = UserRepository();

  @override
  Future<ExtractedContext?> build() async {
    final latest = await _checkinRepo.getLatestCheckIn();
    return latest?.extractedContext;
  }

  Future<bool> submitCheckin(String text) async {
    if (text.trim().isEmpty) return false;

    state = const AsyncValue.loading();
    try {
      final aiService = ref.read(aiServiceProvider);
      final profile = await _userRepo.getProfile() ??
          UserProfile(
            id: 'default',
            displayName: 'Friend',
            goals: ['Sleep better', 'Wake with intention'],
            sleepPreference: SleepPreference.flexible,
            experienceStyle: ExperienceStyle.calm,
            usualSleepTime: '23:00',
            usualWakeTime: '07:00',
            voicePreference: VoicePreference.neutral_ai,
            onboardingCompleted: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      // 1. Extract context using AI engine (Gemini / Groq / Local Heuristic)
      final extractedContext = await aiService.extractContext(text);

      // 2. Generate personalized night plan & morning plan
      final nightPlan = await aiService.generateNightPlan(extractedContext, profile);
      final morningPlan = await aiService.generateMorningPlan(extractedContext, profile);

      // 3. Save to local repositories
      final checkIn = CheckIn(
        id: const Uuid().v4(),
        rawInput: text,
        extractedContext: extractedContext,
        createdAt: DateTime.now(),
      );

      await _checkinRepo.saveCheckIn(checkIn);
      await _planRepo.saveNightPlan(nightPlan);
      await _planRepo.saveMorningPlan(morningPlan);

      state = AsyncValue.data(extractedContext);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
