import 'package:neend_companion/models/audio_track.dart';

/// Audio catalog containing all available audio tracks in the app.
class AudioCatalog {
  static final List<AudioTrack> _tracks = [
    AudioTrack(
      id: 'rain_gentle',
      name: 'Gentle Rain',
      category: AudioCategory.sleep,
      intensity: 2,
      durationSeconds: 30,
      tags: ['rain', 'nature', 'soothing', 'sleep'],
      assetPath: 'assets/audio/rain_gentle.wav',
      recommendedContext: ['sleep', 'anxiety_relief', 'quick_wind_down'],
      isLoopable: true,
    ),
    AudioTrack(
      id: 'brown_noise',
      name: 'Deep Brown Noise',
      category: AudioCategory.sleep,
      intensity: 1,
      durationSeconds: 30,
      tags: ['brown_noise', 'masking', 'deep_sleep', 'tinnitus'],
      assetPath: 'assets/audio/brown_noise.wav',
      recommendedContext: ['deep_sleep', 'noise_masking', 'focus'],
      isLoopable: true,
    ),
    AudioTrack(
      id: 'ocean_waves',
      name: 'Ocean Waves',
      category: AudioCategory.nature,
      intensity: 2,
      durationSeconds: 30,
      tags: ['ocean', 'water', 'rhythmic', 'calm'],
      assetPath: 'assets/audio/ocean_waves.wav',
      recommendedContext: ['relaxation', 'sleep', 'stress_relief'],
      isLoopable: true,
    ),
    AudioTrack(
      id: 'soft_piano',
      name: 'Peaceful Piano Harmonies',
      category: AudioCategory.calming,
      intensity: 2,
      durationSeconds: 28,
      tags: ['piano', 'instrumental', 'melodic', 'warm'],
      assetPath: 'assets/audio/soft_piano.wav',
      recommendedContext: ['reflection', 'calming', 'wind_down'],
      isLoopable: false,
    ),
    AudioTrack(
      id: 'wind_chimes',
      name: 'Crystal Wind Chimes',
      category: AudioCategory.ambient,
      intensity: 1,
      durationSeconds: 25,
      tags: ['chimes', 'breeze', 'meditation', 'solfeggio'],
      assetPath: 'assets/audio/wind_chimes.wav',
      recommendedContext: ['breathwork', 'relaxation', 'peace'],
      isLoopable: true,
    ),
    AudioTrack(
      id: 'morning_birds',
      name: 'Morning Birds & Dawn Breeze',
      category: AudioCategory.morning_energy,
      intensity: 2,
      durationSeconds: 25,
      tags: ['birds', 'morning', 'dawn', 'awakening'],
      assetPath: 'assets/audio/morning_birds.wav',
      recommendedContext: ['morning_activation', 'wake_up', 'gentle_energy'],
      isLoopable: true,
    ),
    AudioTrack(
      id: 'alarm_gentle',
      name: 'Progressive Sunrise Chime',
      category: AudioCategory.morning_energy,
      intensity: 3,
      durationSeconds: 20,
      tags: ['alarm', 'chime', 'rising', 'wake'],
      assetPath: 'assets/audio/alarm_gentle.wav',
      recommendedContext: ['alarm', 'wake_time'],
      isLoopable: true,
    ),
  ];

  static List<AudioTrack> getAll() => List.unmodifiable(_tracks);

  static List<AudioTrack> getByCategory(AudioCategory category) {
    return _tracks.where((track) => track.category == category).toList();
  }

  static AudioTrack? getById(String id) {
    try {
      return _tracks.firstWhere((track) => track.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<AudioTrack> getRecommended(String context, String timeOfDay) {
    if (timeOfDay == 'night' || timeOfDay == 'evening') {
      return _tracks
          .where((track) =>
              track.category == AudioCategory.sleep ||
              track.category == AudioCategory.calming ||
              track.category == AudioCategory.nature ||
              track.category == AudioCategory.ambient)
          .toList();
    } else {
      return _tracks
          .where((track) =>
              track.category == AudioCategory.morning_energy ||
              track.category == AudioCategory.ambient)
          .toList();
    }
  }
}
