import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/models/morning_plan.dart';

class MorningController extends StateNotifier<AsyncValue<MorningPlan?>> {
  MorningController() : super(const AsyncValue.loading()) {
    _loadMorningPlan();
  }

  void _loadMorningPlan() {
    // Simulated morning plan
    final plan = MorningPlan(
      wakeTime: DateTime.now(),
      theme: 'Energetic',
      steps: [
        MorningStep(stepOrder: 1, title: 'Hydrate', interventionId: 'hydrate_1', durationMinutes: 2, instructions: 'Drink a full glass of water.'),
        MorningStep(stepOrder: 2, title: 'Stretch', interventionId: 'stretch_1', durationMinutes: 5, instructions: 'Do some light stretching.'),
      ],
      affirmation: 'Today is a wonderful day to be alive.',
      createdAt: DateTime.now(),
    );
    state = AsyncValue.data(plan);
  }
}

final morningControllerProvider = StateNotifierProvider<MorningController, AsyncValue<MorningPlan?>>((ref) {
  return MorningController();
});
