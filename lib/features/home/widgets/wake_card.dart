import 'package:flutter/material.dart';
import 'package:neend_companion/app/theme/app_colors.dart';

class WakeCard extends StatelessWidget {
  final String alarmTime;
  final VoidCallback onTap;

  const WakeCard({
    Key? key,
    required this.alarmTime,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.nightSurface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.nightTextMuted.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.morningAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm, color: AppColors.morningAccent),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wake Time',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.nightTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alarmTime,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.nightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.nightTextMuted),
          ],
        ),
      ),
    );
  }
}
