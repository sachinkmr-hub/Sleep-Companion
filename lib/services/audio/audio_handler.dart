import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class NeendAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  Timer? _stopTimer;
  Timer? _fadeTimer;

  NeendAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    _stopTimer?.cancel();
    _fadeTimer?.cancel();
    await _player.stop();
    await super.stop();
  }

  Future<void> setAudioSource(AudioSource source) async {
    await _player.setAudioSource(source);
  }

  void setLooping(bool loop) {
    _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
  }

  void fadeOut(Duration duration) {
    _fadeTimer?.cancel();
    const steps = 20;
    final stepDuration = Duration(milliseconds: duration.inMilliseconds ~/ steps);
    double currentVolume = _player.volume;
    final volumeStep = currentVolume / steps;

    _fadeTimer = Timer.periodic(stepDuration, (timer) async {
      currentVolume -= volumeStep;
      if (currentVolume <= 0.05) {
        timer.cancel();
        await stop();
      } else {
        await _player.setVolume(currentVolume);
      }
    });
  }

  void setAutoStopTimer(Duration duration) {
    _stopTimer?.cancel();
    _stopTimer = Timer(duration, () {
      fadeOut(const Duration(seconds: 15));
    });
  }

  AudioPlayer get player => _player;
}
