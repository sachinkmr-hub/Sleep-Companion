import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'night_controller.dart';

class NightExperienceScreen extends ConsumerStatefulWidget {
  const NightExperienceScreen({super.key});

  @override
  ConsumerState<NightExperienceScreen> createState() => _NightExperienceScreenState();
}

class _NightExperienceScreenState extends ConsumerState<NightExperienceScreen> with TickerProviderStateMixin {
  /// Breathing, reflection, soundscape.
  static const int _totalSteps = 3;

  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  void _showFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F36),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Have a peaceful night", style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C842),
              ),
              child: const Text("Goodnight", style: TextStyle(color: Color(0xFF1A1F36))),
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(nightControllerProvider).value ?? 0;
    final timeStr = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.black, // Ultra-dark
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 24,
              child: Text(
                timeStr,
                style: const TextStyle(
                  color: Color(0xFF8B9DC3),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF8B9DC3)),
                onPressed: () => context.pop(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentStep == 0) ...[
                    // Breathing visualization
                    AnimatedBuilder(
                      animation: _breatheController,
                      builder: (context, child) {
                        return Container(
                          width: 200 + (_breatheController.value * 100),
                          height: 200 + (_breatheController.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFF5C842).withOpacity(0.5),
                                const Color(0xFF1A1F36).withOpacity(0.0),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _breatheController.status == AnimationStatus.forward ? "Breathe In" : "Breathe Out",
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        );
                      }
                    )
                  ] else if (currentStep == 1) ...[
                    // Reflection
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        "Let go of today's stress. Tomorrow is a new beginning.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Soundscape
                    const Icon(Icons.waves, color: Color(0xFFF5C842), size: 100),
                    const SizedBox(height: 32),
                    const Text(
                      "Drift to sleep...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalSteps, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentStep ? const Color(0xFFF5C842) : const Color(0xFF1A1F36),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        onPressed: () => ref.read(nightControllerProvider.notifier).previousStep(),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                        onPressed: () {},
                        iconSize: 64,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        onPressed: () {
                          if (currentStep < _totalSteps - 1) {
                            ref
                                .read(nightControllerProvider.notifier)
                                .nextStep(_totalSteps);
                          } else {
                            _showFeedbackSheet();
                          }
                        },
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
