import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/features/morning/morning_controller.dart';
import 'package:neend_companion/models/morning_plan.dart';

class MorningExperienceScreen extends ConsumerStatefulWidget {
  const MorningExperienceScreen({super.key});

  @override
  ConsumerState<MorningExperienceScreen> createState() => _MorningExperienceScreenState();
}

class _MorningExperienceScreenState extends ConsumerState<MorningExperienceScreen> {
  int _currentStepIndex = 0;

  void _nextStep(MorningPlan plan) {
    if (_currentStepIndex < plan.steps.length) {
      setState(() => _currentStepIndex++);
    } else {
      // Done with morning flow
      context.go('/'); // Back to home
    }
  }

  @override
  Widget build(BuildContext context) {
    final morningState = ref.watch(morningControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7), // Morning bg
      body: SafeArea(
        child: morningState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (plan) {
            if (plan == null) return const Center(child: Text('No morning plan available.'));
            
            final isGreeting = _currentStepIndex == 0;
            final isClosing = _currentStepIndex == plan.steps.length;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGreeting) ...[
                    const Text('Good morning!', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: Color(0xFF2D3142))),
                    const SizedBox(height: 16),
                    Text(plan.affirmation, style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Color(0xFFFF8C42))),
                  ] else if (isClosing) ...[
                    const Text('Have a great day!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                    const SizedBox(height: 24),
                    const Text('How are you feeling today?', style: TextStyle(fontSize: 18, color: Color(0xFF2D3142))),
                    // Emoji feedback buttons could go here
                  ] else ...[
                    Text('Step $_currentStepIndex', style: const TextStyle(fontSize: 16, color: Color(0xFF8B9DC3))),
                    const SizedBox(height: 8),
                    Text(plan.steps[_currentStepIndex - 1].title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                    const SizedBox(height: 16),
                    Text(plan.steps[_currentStepIndex - 1].instructions, style: const TextStyle(fontSize: 18, color: Color(0xFF2D3142))),
                    const SizedBox(height: 8),
                    Text('\${plan.steps[_currentStepIndex - 1].durationMinutes} mins', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFF8C42))),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _nextStep(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(isClosing ? 'Finish' : 'Next', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
