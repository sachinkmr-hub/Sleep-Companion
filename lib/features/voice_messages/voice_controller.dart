import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/models/voice_message.dart';

class VoiceController extends StateNotifier<AsyncValue<List<VoiceMessage>>> {
  VoiceController() : super(const AsyncValue.data([])) {
    _loadVoices();
  }

  void _loadVoices() {
    // Load from DB
    state = const AsyncValue.data([]);
  }

  void deleteVoice(String id) {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((v) => v.id != id).toList());
  }
}

final voiceControllerProvider = StateNotifierProvider<VoiceController, AsyncValue<List<VoiceMessage>>>((ref) {
  return VoiceController();
});
