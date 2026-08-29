import 'package:flutter/material.dart';

class FeedbackOption {
  final String emoji;
  final String label;

  const FeedbackOption({required this.emoji, required this.label});
}

class FeedbackSelector extends StatefulWidget {
  final String question;
  final List<FeedbackOption> options;
  final ValueChanged<FeedbackOption> onSelected;
  final FeedbackOption? initialSelection;

  const FeedbackSelector({
    super.key,
    required this.question,
    required this.options,
    required this.onSelected,
    this.initialSelection,
  });

  @override
  State<FeedbackSelector> createState() => _FeedbackSelectorState();
}

class _FeedbackSelectorState extends State<FeedbackSelector> {
  FeedbackOption? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.options.map((option) {
            final isSelected = _selectedOption == option;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedOption = option);
                widget.onSelected(option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF5C842).withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF5C842) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFF5C842) : const Color(0xFF8B9DC3),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
