import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:neend_companion/models/audio_track.dart';
import 'package:neend_companion/services/audio/audio_handler.dart';

class AudioPlayerService {
  NeendAudioHandler? _audioHandler;

  Future<void> init() async {
    _audioHandler = await AudioService.init(
      builder: () => NeendAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.neend.companion.channel.audio',
        androidNotificationChannelName: 'Neend Sleep Audio',
        androidNotificationOngoing: true,
      ),
    );
  }

  Future<void> playTrack(AudioTrack track) async {
    if (_audioHandler == null) await init();
    if (_audioHandler == null) return;

    final item = MediaItem(
      id: track.id,
      title: track.name,
      artist: 'Neend Companion',
      duration: Duration(seconds: track.durationSeconds),
    );

    _audioHandler!.mediaItem.add(item);

    final source = track.assetPath.startsWith('http')
        ? AudioSource.uri(Uri.parse(track.assetPath))
        : AudioSource.uri(Uri.parse('asset:///${track.assetPath}'));

    await _audioHandler!.setAudioSource(source);
    _audioHandler!.setLooping(track.isLoopable);
    await _audioHandler!.play();
  }

  Future<void> playSequence(List<AudioTrack> tracks) async {
    if (tracks.isEmpty) return;
    if (_audioHandler == null) await init();
    if (_audioHandler == null) return;

    final sources = tracks.map((track) {
      return track.assetPath.startsWith('http')
          ? AudioSource.uri(Uri.parse(track.assetPath))
          : AudioSource.uri(Uri.parse('asset:///${track.assetPath}'));
    }).toList();

    final playlist = ConcatenatingAudioSource(children: sources);
    await _audioHandler!.setAudioSource(playlist);
    await _audioHandler!.play();
  }

  void setVolume(double volume) {
    _audioHandler?.setVolume(volume);
  }

  void fadeVolume(double from, double to, int durationSeconds) {
    _audioHandler?.fadeOut(Duration(seconds: durationSeconds));
  }

  void setLooping(bool loop) {
    _audioHandler?.setLooping(loop);
  }

  void setAutoStopTimer(Duration duration) {
    _audioHandler?.setAutoStopTimer(duration);
  }

  Future<void> pause() async {
    await _audioHandler?.pause();
  }

  Future<void> resume() async {
    await _audioHandler?.play();
  }

  Future<void> stop() async {
    await _audioHandler?.stop();
  }

  Stream<bool> get playingStream =>
      _audioHandler?.player.playingStream ?? const Stream.empty();

  Stream<Duration> get positionStream =>
      _audioHandler?.player.positionStream ?? const Stream.empty();

  void dispose() {
    _audioHandler?.stop();
  }
}
