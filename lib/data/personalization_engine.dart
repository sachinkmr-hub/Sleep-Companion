import 'package:neend_companion/models/extracted_context.dart';
import 'package:neend_companion/models/feedback_entry.dart';
import 'package:neend_companion/models/intervention.dart';
import 'package:neend_companion/models/user_profile.dart';
import 'package:neend_companion/data/intervention_registry.dart';

/// Personalization engine that scores and recommends interventions
/// based on user context, preferences, and feedback history.
///
/// This is a rule-based recommendation system for MVP.
/// It does NOT claim to be clinically validated.
/// It uses explicit user feedback to improve over time.
class PersonalizationEngine {
  /// Score an intervention for a given context and user.
  ///
  /// Returns a score from 0.0 to 1.0 indicating how well
  /// this intervention matches the current situation.
  static double scoreIntervention({
    required Intervention intervention,
    required ExtractedContext context,
    required UserProfile profile,
    List<FeedbackEntry> recentFeedback = const [],
  }) {
    double score = 0.5; // Base score

    // 1. Context matching
    score += _contextMatchScore(intervention, context);

    // 2. User preference alignment
    score += _preferenceScore(intervention, profile);

    // 3. Feedback-based adjustment
    score += _feedbackScore(intervention.id, recentFeedback);

    // 4. Energy-level matching
    score += _energyMatchScore(intervention, context.energyLevel);

    // Clamp to 0.0 - 1.0
    return score.clamp(0.0, 1.0);
  }

  /// Get recommended night interventions, sorted by score.
  static List<ScoredIntervention> recommendNightInterventions({
    required ExtractedContext context,
    required UserProfile profile,
    List<FeedbackEntry> recentFeedback = const [],
    int maxSteps = 4,
  }) {
    final nightInterventions = InterventionRegistry.getNightInterventions();
    final scored = nightInterventions.map((intervention) {
      final score = scoreIntervention(
        intervention: intervention,
        context: context,
        profile: profile,
        recentFeedback: recentFeedback,
      );
      return ScoredIntervention(intervention: intervention, score: score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    // Build a balanced plan:
    // 1. One active exercise (breathing/relaxation)
    // 2. One cognitive (if stressors present)
    // 3. One sleep sound (always end with this)
    final plan = <ScoredIntervention>[];

    // Add cognitive first if stressors present
    if (context.stressors.isNotEmpty) {
      final cognitive = scored.firstWhere(
        (s) => s.intervention.category == InterventionCategory.cognitive,
        orElse: () => scored.first,
      );
      plan.add(cognitive);
    }

    // Add top-scoring breathwork or relaxation
    final activeExercise = scored.firstWhere(
      (s) =>
          s.intervention.category == InterventionCategory.breathwork ||
          s.intervention.category == InterventionCategory.relaxation,
      orElse: () => scored.first,
    );
    if (!plan.contains(activeExercise)) {
      plan.add(activeExercise);
    }

    // Always end with sleep audio
    final sleepAudio = scored.firstWhere(
      (s) => s.intervention.category == InterventionCategory.sleepAudio,
      orElse: () => scored.last,
    );
    if (!plan.contains(sleepAudio)) {
      plan.add(sleepAudio);
    }

    // Fill remaining slots with top-scored unused interventions
    for (final s in scored) {
      if (plan.length >= maxSteps) break;
      if (!plan.contains(s)) {
        plan.add(s);
      }
    }

    return plan.take(maxSteps).toList();
  }

  /// Get recommended morning interventions, sorted by score.
  static List<ScoredIntervention> recommendMorningInterventions({
    required ExtractedContext context,
    required UserProfile profile,
    List<FeedbackEntry> recentFeedback = const [],
    int maxSteps = 3,
  }) {
    final morningInterventions =
        InterventionRegistry.getMorningInterventions();
    final scored = morningInterventions.map((intervention) {
      final score = scoreIntervention(
        intervention: intervention,
        context: context,
        profile: profile,
        recentFeedback: recentFeedback,
      );
      return ScoredIntervention(intervention: intervention, score: score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    // Always include hydration as first step
    final hydration = scored.firstWhere(
      (s) => s.intervention.id == 'INT_WAKE_HYDRATE',
      orElse: () => scored.first,
    );

    final plan = <ScoredIntervention>[hydration];

    // Add goal priming if tomorrow has goals
    if (context.tomorrowGoals.isNotEmpty) {
      final priming = scored.firstWhere(
        (s) => s.intervention.id == 'INT_WAKE_PRIMING',
        orElse: () => scored.first,
      );
      if (!plan.contains(priming)) {
        plan.add(priming);
      }
    }

    // Fill remaining
    for (final s in scored) {
      if (plan.length >= maxSteps) break;
      if (!plan.contains(s)) {
        plan.add(s);
      }
    }

    return plan.take(maxSteps).toList();
  }

  // --- Private scoring functions ---

  static double _contextMatchScore(
    Intervention intervention,
    ExtractedContext context,
  ) {
    double score = 0.0;
    final recommended = intervention.recommendedContext;

    // Check if the intervention's recommended contexts match the user's state
    if (context.sleepPreference == 'anxiety_relief' &&
        recommended.contains('anxiety')) {
      score += 0.15;
    }
    if (context.sleepPreference == 'anxiety_relief' &&
        recommended.contains('racing thoughts')) {
      score += 0.1;
    }
    if (context.sleepPreference == 'quick_wind_down' &&
        recommended.contains('sleep onset')) {
      score += 0.15;
    }
    if (context.stressors.isNotEmpty &&
        recommended.contains('stress')) {
      score += 0.1;
    }
    if (context.stressors.isNotEmpty &&
        recommended.contains('high stressor load')) {
      score += 0.15;
    }
    if (context.desiredExperience == 'breathwork' &&
        intervention.category == InterventionCategory.breathwork) {
      score += 0.15;
    }
    if (context.desiredExperience == 'body_scan' &&
        intervention.id == 'INT_BODY_SCAN') {
      score += 0.15;
    }
    if (context.desiredExperience == 'soundscape_only' &&
        intervention.category == InterventionCategory.sleepAudio) {
      score += 0.2;
    }

    return score;
  }

  static double _preferenceScore(
    Intervention intervention,
    UserProfile profile,
  ) {
    double score = 0.0;

    // Match experience style preference
    switch (profile.experienceStyle) {
      case ExperienceStyle.calm:
        if (intervention.category == InterventionCategory.relaxation ||
            intervention.category == InterventionCategory.sleepAudio) {
          score += 0.1;
        }
        break;
      case ExperienceStyle.minimal:
        // Prefer shorter interventions
        if (intervention.recommendedDurationMin <= 5) {
          score += 0.1;
        }
        break;
      case ExperienceStyle.warm:
        if (intervention.category == InterventionCategory.relaxation) {
          score += 0.1;
        }
        break;
      case ExperienceStyle.motivating:
        if (intervention.category == InterventionCategory.morningActivation) {
          score += 0.1;
        }
        break;
    }

    return score;
  }

  static double _feedbackScore(
    String interventionId,
    List<FeedbackEntry> recentFeedback,
  ) {
    if (recentFeedback.isEmpty) return 0.0;

    // Find feedback entries that included this intervention
    final relevant = recentFeedback.where(
      (f) => f.interventionIds.contains(interventionId),
    );

    if (relevant.isEmpty) return 0.0;

    double totalScore = 0.0;
    int count = 0;

    for (final feedback in relevant) {
      switch (feedback.rating) {
        case 'better':
          totalScore += 0.15;
          break;
        case 'good':
          totalScore += 0.05;
          break;
        case 'same':
          totalScore += 0.0;
          break;
        case 'didnt_help':
          totalScore -= 0.15;
          break;
        case 'energized':
          totalScore += 0.15;
          break;
        case 'okay':
          totalScore += 0.05;
          break;
        case 'tired':
          totalScore -= 0.05;
          break;
        case 'stressed':
          totalScore -= 0.1;
          break;
      }
      count++;
    }

    // Average and weight by recency
    return count > 0 ? (totalScore / count) : 0.0;
  }

  static double _energyMatchScore(
    Intervention intervention,
    String energyLevel,
  ) {
    double score = 0.0;

    switch (energyLevel) {
      case 'exhausted':
        // Prefer short, passive interventions
        if (intervention.category == InterventionCategory.sleepAudio) {
          score += 0.15;
        }
        if (intervention.recommendedDurationMin <= 5) {
          score += 0.05;
        }
        // Penalize long active exercises
        if (intervention.recommendedDurationMin > 10) {
          score -= 0.1;
        }
        break;
      case 'wired_tired':
        // Prefer breathing and cognitive offloading
        if (intervention.category == InterventionCategory.breathwork) {
          score += 0.15;
        }
        if (intervention.category == InterventionCategory.cognitive) {
          score += 0.1;
        }
        break;
      case 'low':
        // Gentle relaxation
        if (intervention.category == InterventionCategory.relaxation) {
          score += 0.1;
        }
        break;
      case 'neutral':
        // No strong preference
        break;
      case 'high':
        // Need active wind-down
        if (intervention.category == InterventionCategory.breathwork) {
          score += 0.1;
        }
        if (intervention.category == InterventionCategory.relaxation) {
          score += 0.1;
        }
        break;
    }

    return score;
  }
}

/// An intervention with its computed relevance score.
class ScoredIntervention {
  final Intervention intervention;
  final double score;

  const ScoredIntervention({
    required this.intervention,
    required this.score,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoredIntervention &&
          runtimeType == other.runtimeType &&
          intervention.id == other.intervention.id;

  @override
  int get hashCode => intervention.id.hashCode;
}
