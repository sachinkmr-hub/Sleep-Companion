import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/services/alarm/alarm_service.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});
