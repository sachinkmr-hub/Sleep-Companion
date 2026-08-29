import 'package:neend_companion/services/ai/ai_service.dart';
import 'package:neend_companion/models/extracted_context.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/models/night_plan.dart';
import 'package:neend_companion/models/morning_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpenAiService implements AiService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<ExtractedContext> extractContext(String userInput) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'extract-context',
        body: {'userInput': userInput},
      ).timeout(const Duration(seconds: 15));
      
      return ExtractedContext.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Fallback on error
      return ExtractedContext(
        moodContext: 'Neutral',
        stressors: [],
        tomorrowGoals: [],
        sleepPreference: '',
        energyLevel: 'Normal',
        desiredExperience: 'Calm',
        languageDetected: 'en',
      );
    }
  }

  @override
  Future<NightPlan> generateNightPlan(ExtractedContext context, UserProfile profile) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'generate-night-plan',
        body: {
          'context': context.toJson(),
          'profile': profile.toJson(),
        },
      ).timeout(const Duration(seconds: 20));
      
      return NightPlan.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Fallback minimal plan
      return NightPlan(
        theme: 'Calm Night',
        estimatedDurationMinutes: 15,
        recommendedBedtime: profile.usualSleepTime,
        steps: [],
        windDownQuote: 'Rest well.',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<MorningPlan> generateMorningPlan(ExtractedContext context, UserProfile profile) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'generate-morning-plan',
        body: {
          'context': context.toJson(),
          'profile': profile.toJson(),
        },
      ).timeout(const Duration(seconds: 20));
      
      return MorningPlan.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Fallback
      return MorningPlan(
        wakeTime: profile.usualWakeTime,
        theme: 'Fresh Morning',
        steps: [],
        affirmation: 'Today is a good day.',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<String> generateConfirmation(String userInput, ExtractedContext context) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'generate-confirmation',
        body: {
          'userInput': userInput,
          'context': context.toJson(),
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.data['confirmation'] as String;
    } catch (e) {
      return "Got it. I'll prepare everything based on what you told me.";
    }
  }
}
