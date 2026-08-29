import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'checkin_controller.dart';
import 'widgets/voice_input_sheet.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showVoiceInput(BuildContext context) async {
    final transcribedText = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1F36),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const VoiceInputSheet(),
    );

    if (transcribedText != null && transcribedText.isNotEmpty) {
      setState(() {
        _textController.text = transcribedText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkinControllerProvider);
    final hasText = _textController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),
              const Text(
                "How was your day?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F36),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          maxLength: 1000,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Tell me about your day, what's on your mind for tomorrow...",
                            hintStyle: TextStyle(
                              color: Color(0xFF8B9DC3),
                              fontSize: 18,
                            ),
                            border: InputBorder.none,
                            counterStyle: TextStyle(color: Color(0xFF8B9DC3)),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            heroTag: 'voice_mic',
                            onPressed: () => _showVoiceInput(context),
                            backgroundColor: const Color(0xFFF5C842),
                            child: const Icon(Icons.mic, color: Color(0xFF1A1F36)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (state.hasError) ...[
                Text(
                  state.error.toString(),
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: hasText && !state.isLoading
                      ? () async {
                          final success = await ref
                              .read(checkinControllerProvider.notifier)
                              .submitCheckin(_textController.text);
                          if (success && context.mounted) {
                            context.go('/night-plan');
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5C842),
                    disabledBackgroundColor: const Color(0xFF1A1F36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF1A1F36))
                      : Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hasText ? const Color(0xFF1A1F36) : const Color(0xFF8B9DC3),
                          ),
                        ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
