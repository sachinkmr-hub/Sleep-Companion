import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:neend_companion/services/notification/notification_service.dart';

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Neend Alarm fired with id: $id');

  // 1. Trigger Full-Screen Intent Notification over Lockscreen
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.showAlarmNotification(id);

  // 2. Progressive Awakening Audio Playback
  try {
    final player = AudioPlayer();
    await player.setAsset('assets/audio/alarm_gentle.wav');
    await player.setLoopMode(LoopMode.one);
    await player.setVolume(0.1);
    await player.play();

    // Gradually ramp volume from 10% to 100% over 30 seconds
    double currentVolume = 0.1;
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (currentVolume >= 1.0 || !player.playing) {
        timer.cancel();
      } else {
        currentVolume = (currentVolume + 0.1).clamp(0.0, 1.0);
        await player.setVolume(currentVolume);
      }
    });

    log('Alarm progressive audio playback started successfully');
  } catch (e) {
    log('Alarm audio playback notice: $e');
  }
}
