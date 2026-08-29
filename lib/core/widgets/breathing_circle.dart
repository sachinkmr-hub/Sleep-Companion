import 'package:flutter/material.dart';

class BreathingCircle extends StatefulWidget {
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int totalCycles;
  final VoidCallback? onComplete;
  final bool isPlaying;

  const BreathingCircle({
    super.key,
    this.inhaleSeconds = 4,
    this.holdSeconds = 7,
    this.exhaleSeconds = 8,
    this.totalCycles = 4,
    this.onComplete,
    this.isPlaying = true,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

enum BreathPhase { inhale, hold, exhale, done }

class _BreathingCircleState extends State<BreathingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  BreathPhase _phase = BreathPhase.inhale;
  int _currentCycle = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _setupAnimation();
    if (widget.isPlaying) {
      _startCycle();
    }
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying && _phase != BreathPhase.done) {
        _startCycle();
      } else {
        _controller.stop();
      }
    }
  }

  void _setupAnimation() {
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  Future<void> _startCycle() async {
    if (_currentCycle > widget.totalCycles || !mounted) {
      setState(() => _phase = BreathPhase.done);
      widget.onComplete?.call();
      return;
    }

    if (!widget.isPlaying) return;

    // Inhale
    setState(() => _phase = BreathPhase.inhale);
    _controller.duration = Duration(seconds: widget.inhaleSeconds);
    await _controller.forward();

    if (!mounted || !widget.isPlaying) return;

    // Hold
    setState(() => _phase = BreathPhase.hold);
    await Future.delayed(Duration(seconds: widget.holdSeconds));

    if (!mounted || !widget.isPlaying) return;

    // Exhale
    setState(() => _phase = BreathPhase.exhale);
    _controller.duration = Duration(seconds: widget.exhaleSeconds);
    await _controller.reverse();

    if (!mounted || !widget.isPlaying) return;

    _currentCycle++;
    _startCycle();
  }

  String get _phaseText {
    switch (_phase) {
      case BreathPhase.inhale: return "Breathe in...";
      case BreathPhase.hold: return "Hold...";
      case BreathPhase.exhale: return "Breathe out...";
      case BreathPhase.done: return "Complete";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Cycle $_currentCycle / ${widget.totalCycles}",
          style: const TextStyle(color: Color(0xFF8B9DC3), fontSize: 16),
        ),
        const SizedBox(height: 60),
        SizedBox(
          height: 250,
          child: Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Container(
                  width: 80 * _scaleAnimation.value,
                  height: 80 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5C842).withOpacity(0.3),
                    border: Border.all(
                      color: const Color(0xFFF5C842),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF5C842).withOpacity(0.4),
                        blurRadius: 20 * _scaleAnimation.value,
                        spreadRadius: 5 * _scaleAnimation.value,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 60),
        Text(
          _phaseText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
