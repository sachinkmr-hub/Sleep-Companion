import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/models/alarm_data.dart';
import 'package:neend_companion/services/alarm/alarm_provider.dart';

class AlarmController extends StateNotifier<AsyncValue<AlarmData?>> {
  final Ref _ref;

  AlarmController(this._ref) : super(const AsyncValue.data(null)) {
    _loadAlarm();
  }

  void _loadAlarm() {
    // In a real app, read from local DB
    state = const AsyncValue.data(null);
  }

  Future<void> setAlarm(AlarmData alarm) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(alarmServiceProvider).scheduleAlarm(alarm);
      state = AsyncValue.data(alarm);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelAlarm() async {
    final current = state.value;
    if (current != null) {
      await _ref.read(alarmServiceProvider).cancelAlarm(current.id);
      state = const AsyncValue.data(null);
    }
  }
}

final alarmControllerProvider = StateNotifierProvider<AlarmController, AsyncValue<AlarmData?>>((ref) {
  return AlarmController(ref);
});
