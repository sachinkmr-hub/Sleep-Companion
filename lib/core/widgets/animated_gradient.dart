import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final TimeOfDay? timeOfDay;
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    this.timeOfDay,
    required this.child,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getColorsForTime(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 21 || hour < 5) {
      // Night (9PM-5AM): deep navy to dark purple
      return const [Color(0xFF0A0E1A), Color(0xFF1A1F36), Color(0xFF0A0E1A)];
    } else if (hour >= 5 && hour < 7) {
      // Dawn (5AM-7AM): dark purple to warm orange
      return const [Color(0xFF1A1F36), Color(0xFF4A2B4D), Color(0xFFFF8C42)];
    } else if (hour >= 7 && hour < 12) {
      // Morning (7AM-12PM): warm cream to soft gold
      return const [Color(0xFFFFF8E7), Color(0xFFFDE8CD), Color(0xFFF5C842)];
    } else if (hour >= 12 && hour < 18) {
      // Day (12PM-6PM): soft blue-white
      return const [Color(0xFFE6F0FA), Color(0xFFD4E4F7), Color(0xFFB9D6F2)];
    } else {
      // Evening (6PM-9PM): warm amber to deep blue
      return const [Color(0xFFF5C842), Color(0xFF4A2B4D), Color(0xFF1A1F36)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.timeOfDay ?? TimeOfDay.now();
    final colors = _getColorsForTime(time);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [
                0.0,
                0.5 + (_controller.value * 0.1),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
