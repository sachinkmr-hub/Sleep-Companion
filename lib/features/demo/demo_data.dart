class DemoData {
  static const Map<String, dynamic> demoProfile = {
    'id': 'demo_user_1',
    'displayName': 'Rahul',
    'goals': ['Reduce stress', 'Wake up early for running'],
    'experienceStyle': 'calm',
    'usualSleepTime': '22:30',
    'usualWakeTime': '06:30',
    'voicePreference': 'default',
    'onboardingCompleted': true,
  };

  static const Map<String, dynamic> demoCheckIn = {
    'id': 'demo_checkin_1',
    'text': 'Aaj interview ki wajah se stressed tha. Kal 5 baje running ke liye uthna hai.',
    'timestamp': '2023-10-27T21:00:00Z',
  };

  static const Map<String, dynamic> demoExtractedContext = {
    'moodContext': 'stressed due to interview',
    'stressors': ['interview'],
    'tomorrowGoals': ['running at 5 AM'],
    'wakeTime': '05:00',
    'sleepPreference': 'calming',
    'energyLevel': 'low',
    'desiredExperience': 'relaxation and early wake up',
  };

  static const Map<String, dynamic> demoNightPlan = {
    'theme': 'Stress Relief & Deep Sleep',
    'estimatedDurationMinutes': 25,
    'recommendedBedtime': '22:00',
    'steps': [
      {
        'stepOrder': 1,
        'title': 'Box Breathing',
        'interventionId': 'breath_box_1',
        'durationMinutes': 5,
        'instructions': 'Inhale for 4s, hold for 4s, exhale for 4s, hold for 4s.',
        'soundscape': 'ambient_drone',
      },
      {
        'stepOrder': 2,
        'title': 'Calming Audio',
        'interventionId': 'audio_calm_1',
        'durationMinutes': 10,
        'instructions': 'Listen to this guided relaxation.',
        'soundscape': 'soft_rain',
      },
      {
        'stepOrder': 3,
        'title': 'Deep Sleep Sounds',
        'interventionId': 'sound_sleep_1',
        'durationMinutes': 10,
        'instructions': 'Drift off to sleep.',
        'soundscape': 'brown_noise',
      }
    ],
    'windDownQuote': 'Let go of today. Tomorrow is a new start.',
  };

  static const Map<String, dynamic> demoMorningPlan = {
    'wakeTime': '05:00',
    'theme': 'Energized for Running',
    'steps': [
      {
        'stepOrder': 1,
        'title': 'Hydrate',
        'interventionId': 'morn_hydrate_1',
        'durationMinutes': 2,
        'instructions': 'Drink a glass of water.',
      },
      {
        'stepOrder': 2,
        'title': 'Goal Reminder',
        'interventionId': 'morn_goal_1',
        'durationMinutes': 3,
        'instructions': 'Get ready for your run!',
      }
    ],
    'affirmation': 'I am ready and energized for my morning run.',
  };

  static const Map<String, dynamic> demoAlarmData = {
    'id': 'demo_alarm_1',
    'scheduledTime': '05:00:00', // e.g. next day 5am
    'label': 'Morning Run',
    'tomorrowGoal': 'running at 5 AM',
    'isEnabled': true,
    'voiceMessageId': 'demo_voice_1',
  };

  static const Map<String, String> demoTtsMessages = {
    'night': "You're carrying some stress from today's interview. Let's slow things down and prepare you for tomorrow's run.",
    'morning': "Good morning Rahul. You wanted to run today. Let's get up and moving."
  };

  static const Map<String, dynamic> demoFeedback = {
    'rating': 4,
    'notes': 'Demo feedback text',
  };
}
