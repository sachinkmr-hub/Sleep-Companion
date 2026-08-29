import 'package:flutter/material.dart';
import 'package:neend_companion/app/theme/app_colors.dart';

class ContextSummary extends StatelessWidget {
  final String message;

  const ContextSummary({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.nightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.nightTextMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.nightTextMuted,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
