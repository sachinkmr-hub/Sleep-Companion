import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:neend_companion/data/repositories/user_repository.dart';

// Feature screens
import 'package:neend_companion/features/onboarding/onboarding_screen.dart';
import 'package:neend_companion/features/home/home_screen.dart';
import 'package:neend_companion/features/checkin/checkin_screen.dart';
import 'package:neend_companion/features/night/night_plan_screen.dart';
import 'package:neend_companion/features/night/night_experience_screen.dart';
import 'package:neend_companion/features/morning/alarm_screen.dart';
import 'package:neend_companion/features/morning/morning_experience_screen.dart';
import 'package:neend_companion/features/alarm/alarm_setup_screen.dart';
import 'package:neend_companion/features/voice_messages/voice_library_screen.dart';
import 'package:neend_companion/features/voice_messages/record_voice_screen.dart';
import 'package:neend_companion/features/voice_messages/voice_consent_screen.dart';
import 'package:neend_companion/features/settings/settings_screen.dart';
import 'package:neend_companion/features/settings/privacy_screen.dart';
import 'package:neend_companion/features/settings/data_management_screen.dart';
import 'package:neend_companion/features/feedback/night_feedback_sheet.dart';
import 'package:neend_companion/features/feedback/morning_feedback_sheet.dart';

/// App router configuration using GoRouter.
///
/// Routes:
/// - /splash → Loading/initialization screen
/// - /onboarding → First-time user setup
/// - /home → Main hub
/// - /checkin → Daily check-in (text + voice)
/// - /night-plan → Tonight's personalized plan
/// - /night-experience → Immersive night routine
/// - /alarm-ring → Full-screen alarm (launched via notification)
/// - /alarm-setup → Set/modify alarm
/// - /morning → Morning experience
/// - /voice-library → Manage voice clips
/// - /record-voice → Record new voice clip
/// - /voice-consent → Voice consent form
/// - /settings → App settings
/// - /privacy → Privacy information
/// - /data-management → Manage stored data
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // --- Splash / Loading ---
    GoRoute(
      path: '/splash',
      builder: (context, state) => const _SplashScreen(),
    ),

    // --- Onboarding ---
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // --- Home ---
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    // --- Check-in ---
    GoRoute(
      path: '/checkin',
      builder: (context, state) => const CheckinScreen(),
    ),

    // --- Night ---
    GoRoute(
      path: '/night-plan',
      builder: (context, state) => const NightPlanScreen(),
    ),
    GoRoute(
      path: '/night-experience',
      builder: (context, state) => const NightExperienceScreen(),
    ),

    // --- Alarm ---
    GoRoute(
      path: '/alarm-ring',
      builder: (context, state) => const AlarmScreen(),
    ),
    GoRoute(
      path: '/alarm-setup',
      builder: (context, state) => const AlarmSetupScreen(),
    ),

    // --- Morning ---
    GoRoute(
      path: '/morning',
      builder: (context, state) => const MorningExperienceScreen(),
    ),

    // --- Voice Messages ---
    GoRoute(
      path: '/voice-library',
      builder: (context, state) => const VoiceLibraryScreen(),
    ),
    GoRoute(
      path: '/record-voice',
      builder: (context, state) => const RecordVoiceScreen(),
    ),
    GoRoute(
      path: '/voice-consent',
      builder: (context, state) => const VoiceConsentScreen(),
    ),

    // --- Settings ---
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/data-management',
      builder: (context, state) => const DataManagementScreen(),
    ),
  ],
  redirect: (context, state) {
    final path = state.uri.path;

    // Allow splash and alarm-ring without redirect
    if (path == '/splash' || path == '/alarm-ring') {
      return null;
    }

    // Check if onboarding is completed
    final onboarded = _checkOnboarded();

    // If not onboarded, redirect to onboarding (except if already there)
    if (!onboarded && path != '/onboarding') {
      return '/onboarding';
    }

    // If onboarded and trying to go to onboarding, go home
    if (onboarded && path == '/onboarding') {
      return '/home';
    }

    return null;
  },
  errorBuilder: (context, state) => _ErrorScreen(error: state.error),
);

/// Check onboarding status from local storage.
bool _checkOnboarded() => UserRepository.isOnboardedSync();

/// Splash screen shown during app initialization.
/// Redirects to onboarding or home after a brief delay.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Navigate after splash
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    try {
      // Ensure Hive box is open
      if (!Hive.isBoxOpen(UserRepository.boxName)) {
        await Hive.openBox(UserRepository.boxName);
      }

      final onboarded = _checkOnboarded();
      if (mounted) {
        context.go(onboarded ? '/home' : '/onboarding');
      }
    } catch (_) {
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF5C842),
                      const Color(0xFFFF8C42),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  size: 40,
                  color: Color(0xFF0A0E1A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Neend',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFFE8ECF4),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your sleep & morning companion',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8B9DC3),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen for invalid routes.
class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFF5C842),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFE8ECF4),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
