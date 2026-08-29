import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/features/feedback/feedback_controller.dart';
import 'package:go_router/go_router.dart';

class NightFeedbackSheet extends ConsumerStatefulWidget {
  final List<String> interventionIds;

  const NightFeedbackSheet({
    Key? key,
    required this.interventionIds,
  }) : super(key: key);

  @override
  ConsumerState<NightFeedbackSheet> createState() => _NightFeedbackSheetState();
}

class _NightFeedbackSheetState extends ConsumerState<NightFeedbackSheet> {
  int? _selectedRating; // 1 to 4
  bool _showText = false;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _options = [
    {'icon': '😌', 'label': 'Better', 'value': 4},
    {'icon': '🙂', 'label': 'Good', 'value': 3},
    {'icon': '😐', 'label': 'Same', 'value': 2},
    {'icon': '😕', 'label': 'Didn\'t help', 'value': 1},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedRating == null) return;
    
    ref.read(feedbackControllerProvider.notifier).saveFeedback(
      type: 'night',
      rating: _selectedRating!,
      interventionIds: widget.interventionIds,
      sleepDuration: null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    
    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F36),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'How was that?',
            style: TextStyle(
              color: Color(0xFFE8ECF4),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _options.map((option) {
              final isSelected = _selectedRating == option['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = option['value'];
                    _showText = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5C842).withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF5C842) : const Color(0xFF8B9DC3).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(option['icon'], style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        option['label'],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFF5C842) : const Color(0xFF8B9DC3),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_showText) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Color(0xFFE8ECF4)),
              decoration: InputDecoration(
                hintText: 'What would you change? (Optional)',
                hintStyle: const TextStyle(color: Color(0xFF8B9DC3)),
                filled: true,
                fillColor: const Color(0xFF0A0E1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedRating != null ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5C842),
              foregroundColor: const Color(0xFF0A0E1A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF8B9DC3).withOpacity(0.2),
              disabledForegroundColor: const Color(0xFF8B9DC3),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
