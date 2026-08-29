class SleepData {
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;

  SleepData({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });
}

class ActivityData {
  final int steps;
  final int activeMinutes;

  ActivityData({
    required this.steps,
    required this.activeMinutes,
  });
}

abstract class HealthInterface {
  Future<SleepData?> getSleepData();
  Future<ActivityData?> getActivityData();
  Future<bool> isAvailable();
}

class HealthStubImplementation implements HealthInterface {
  @override
  Future<SleepData?> getSleepData() async {
    return null;
  }

  @override
  Future<ActivityData?> getActivityData() async {
    return null;
  }

  @override
  Future<bool> isAvailable() async {
    return false;
  }
}
