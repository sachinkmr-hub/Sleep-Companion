import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/services/ai/ai_service.dart';
import 'package:neend_companion/services/ai/multi_provider_ai_service.dart';

/// Riverpod provider for AI Service.
/// Uses MultiProviderAiService which seamlessly handles:
/// 1. Free Google Gemini 2.0 Flash / 1.5 Flash
/// 2. Free Groq Llama-3.3-70B
/// 3. Zero-cost, 100% offline heuristic semantic extraction engine
final aiServiceProvider = Provider<AiService>((ref) {
  return MultiProviderAiService();
});
