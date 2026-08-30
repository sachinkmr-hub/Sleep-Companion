import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neend_companion/features/feedback/feedback_controller.dart';
import 'package:neend_companion/models/feedback_entry.dart';
import 'package:go_router/go_router.dart';

class MorningFeedbackSheet extends ConsumerStatefulWidget {
  const MorningFeedbackSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<MorningFeedbackSheet> createState() => _MorningFeedbackSheetState();
}

class _MorningFeedbackSheetState extends ConsumerState<MorningFeedbackSheet> {
  String? _selectedRating;
  int _sleepHours = 7;
  int _sleepMinutes = 0;

  final List<Map<String, String>> _options = [
    {'icon': '⚡', 'label': 'Energized', 'value': 'energized'},
    {'icon': '👍', 'label': 'Okay', 'value': 'okay'},
    {'icon': '😴', 'label': 'Tired', 'value': 'tired'},
    {'icon': '😰', 'label': 'Stressed', 'value': 'stressed'},
  ];

  void _submit() {
    if (_selectedRating == null) return;
    
    final sleepDurationMinutes = (_sleepHours * 60) + _sleepMinutes;
    
    ref.read(feedbackControllerProvider.notifier).saveFeedback(
      type: FeedbackType.morning,
      rating: _selectedRating!,
      interventionIds: [], // Empty for morning feedback unless specific interventions are used
      sleepDurationMinutes: sleepDurationMinutes,
      notes: null,
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
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'How do you feel?',
            style: TextStyle(
              color: Color(0xFF2D3142),
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
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF8C42).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF8C42) : const Color(0xFF2D3142).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(option['icon']!, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        option['label']!,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFFF8C42) : const Color(0xFF2D3142),
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
          const SizedBox(height: 32),
          const Text(
            'Sleep last night:',
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D3142).withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _sleepHours,
                      isExpanded: true,
                      dropdownColor: const Color(0xFFFFF8E7),
                      items: List.generate(16, (i) => i).map((hours) {
                        return DropdownMenuItem(
                          value: hours,
                          child: Text('$hours hours', style: const TextStyle(color: Color(0xFF2D3142))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sleepHours = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D3142).withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _sleepMinutes,
                      isExpanded: true,
                      dropdownColor: const Color(0xFFFFF8E7),
                      items: [0, 15, 30, 45].map((mins) {
                        return DropdownMenuItem(
                          value: mins,
                          child: Text('$mins mins', style: const TextStyle(color: Color(0xFF2D3142))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sleepMinutes = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _selectedRating != null ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
              foregroundColor: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF2D3142).withOpacity(0.1),
              disabledForegroundColor: const Color(0xFF2D3142).withOpacity(0.4),
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
