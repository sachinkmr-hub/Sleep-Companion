import 'package:flutter/material.dart';

class MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
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
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.isListening
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF5C842).withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 5,
                      )
                    ]
                  : [],
            ),
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: const Color(0xFFF5C842),
              child: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none,
                color: const Color(0xFF1A1F36),
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}
