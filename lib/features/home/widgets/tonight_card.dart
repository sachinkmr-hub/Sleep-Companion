import 'package:flutter/material.dart';
import 'package:neend_companion/app/theme/app_colors.dart';

class TonightCard extends StatelessWidget {
  final VoidCallback onStart;

  const TonightCard({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tonight',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.nightTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s wind down.',
            style: TextStyle(
              fontSize: 28,
              color: AppColors.nightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nightAccent,
              foregroundColor: AppColors.nightBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            onPressed: onStart,
            child: const Text('Start Tonight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
