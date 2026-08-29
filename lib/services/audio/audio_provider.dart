import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_player_service.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  // Initialize in the background
  service.init();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

final isAudioPlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playingStream;
});

final audioPositionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});
