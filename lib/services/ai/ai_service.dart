import 'package:neend_companion/models/extracted_context.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/models/night_plan.dart';
import 'package:neend_companion/models/morning_plan.dart';

abstract class AiService {
  Future<ExtractedContext> extractContext(String userInput);
  Future<NightPlan> generateNightPlan(ExtractedContext context, UserProfile profile);
  Future<MorningPlan> generateMorningPlan(ExtractedContext context, UserProfile profile);
  Future<String> generateConfirmation(String userInput, ExtractedContext context);
}
