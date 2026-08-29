import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/models/night_plan.dart';
import 'package:neend_companion/data/repositories/plan_repository.dart';
import 'package:neend_companion/data/audio_catalog.dart';
import 'package:neend_companion/services/audio/audio_provider.dart';

final nightPlanProvider = FutureProvider<NightPlan?>((ref) async {
  final planRepo = PlanRepository();
  return await planRepo.getLatestNightPlan();
});

final nightControllerProvider =
    AsyncNotifierProvider<NightController, int>(() {
  return NightController();
});

class NightController extends AsyncNotifier<int> {
  final PlanRepository _planRepo = PlanRepository();

  @override
  Future<int> build() async {
    return 0; // Current step index
  }

  void nextStep(int totalSteps) {
    final current = state.value ?? 0;
    if (current < totalSteps - 1) {
      state = AsyncValue.data(current + 1);
    } else {
      completeExperience();
    }
  }

  void previousStep() {
    final current = state.value ?? 0;
    if (current > 0) {
      state = AsyncValue.data(current - 1);
    }
  }

  Future<void> playStepAudio(String? soundscapeId) async {
    final audioService = ref.read(audioPlayerServiceProvider);
    
    // Map soundscape IDs or default to gentle rain / brown noise
    String trackId = 'rain_gentle';
    if (soundscapeId != null) {
      if (soundscapeId.contains('BROWN')) trackId = 'brown_noise';
      if (soundscapeId.contains('NATURE') || soundscapeId.contains('OCEAN')) trackId = 'ocean_waves';
      if (soundscapeId.contains('PIANO')) trackId = 'soft_piano';
      if (soundscapeId.contains('CHIME')) trackId = 'wind_chimes';
    }

    final track = AudioCatalog.getById(trackId) ?? AudioCatalog.getAll().first;
    await audioService.playTrack(track);
  }

  Future<void> completeExperience() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    // Play loopable sleep rain or brown noise
    final sleepTrack = AudioCatalog.getById('rain_gentle') ?? AudioCatalog.getAll().first;
    await audioService.playTrack(sleepTrack);
    audioService.setAutoStopTimer(const Duration(minutes: 45));
  }

  Future<void> pauseAudio() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.pause();
  }

  Future<void> resumeAudio() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    await audioService.resume();
  }
}
