import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/app/theme/app_colors.dart';
import 'package:neend_companion/core/widgets/animated_gradient.dart';
import 'package:neend_companion/core/widgets/mic_button.dart';
import 'package:neend_companion/features/home/home_controller.dart';
import 'package:neend_companion/features/home/widgets/tonight_card.dart';
import 'package:neend_companion/features/home/widgets/wake_card.dart';
import 'package:neend_companion/features/home/widgets/context_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.nightBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.nightAccent)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24), // Placeholder to keep spacing
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppColors.nightTextMuted),
                        onPressed: () => context.go('/settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.getGreeting(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.nightTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  TonightCard(
                    onStart: () {
                      context.go('/checkin');
                    },
                  ),
                  const SizedBox(height: 24),
                  WakeCard(
                    alarmTime: _controller.alarmTimeDisplay,
                    onTap: () {
                      context.go('/alarm-setup');
                    },
                  ),
                  const SizedBox(height: 24),
                  ContextSummary(
                    message: _controller.contextSummary,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            right: 24,
            child: MicButton(
              isListening: false,
              onPressed: () {
                context.go('/checkin');
              },
            ),
          ),
        ],
      ),
    );
  }
}
