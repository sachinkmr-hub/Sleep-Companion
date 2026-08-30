import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:neend_companion/data/repositories/user_repository.dart';
import 'package:neend_companion/models/user_profile.dart';

/// The router's redirect decides, synchronously, whether onboarding is done.
/// It used to read a `onboarding_completed` key that nothing ever wrote, so it
/// always answered "not onboarded" and bounced the user back to onboarding the
/// moment they finished it. These tests pin the read to the record that
/// [UserRepository.saveProfile] actually writes.
void main() {
  late Directory tempDir;

  UserProfile buildProfile({required bool onboardingCompleted}) {
    final now = DateTime.now();
    return UserProfile(
      id: 'default_user',
      displayName: 'User',
      goals: const ['Sleep better'],
      sleepPreference: SleepPreference.flexible,
      experienceStyle: ExperienceStyle.calm,
      usualSleepTime: '11:00 PM',
      usualWakeTime: '07:00 AM',
      voicePreference: VoicePreference.neutral_ai,
      onboardingCompleted: onboardingCompleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('neend_test');
    Hive.init(tempDir.path);
    await Hive.openBox(UserRepository.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('reports not onboarded before any profile is saved', () {
    expect(UserRepository.isOnboardedSync(), isFalse);
  });

  test('reports onboarded once a completed profile is saved', () async {
    await UserRepository().saveProfile(buildProfile(onboardingCompleted: true));

    expect(UserRepository.isOnboardedSync(), isTrue);
  });

  test('reports not onboarded for a profile that did not finish onboarding',
      () async {
    await UserRepository().saveProfile(buildProfile(onboardingCompleted: false));

    expect(UserRepository.isOnboardedSync(), isFalse);
  });

  test('reports not onboarded after the profile is deleted', () async {
    final repo = UserRepository();
    await repo.saveProfile(buildProfile(onboardingCompleted: true));
    expect(UserRepository.isOnboardedSync(), isTrue);

    await repo.deleteProfile();

    expect(UserRepository.isOnboardedSync(), isFalse);
  });

  test('saved profile round-trips back through getProfile', () async {
    final repo = UserRepository();
    await repo.saveProfile(buildProfile(onboardingCompleted: true));

    final loaded = await repo.getProfile();

    expect(loaded, isNotNull);
    expect(loaded!.onboardingCompleted, isTrue);
    expect(loaded.usualWakeTime, '07:00 AM');
    expect(loaded.experienceStyle, ExperienceStyle.calm);
  });
}
