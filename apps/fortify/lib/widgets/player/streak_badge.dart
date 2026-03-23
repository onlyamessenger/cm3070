import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final bool shieldAvailable;
  final bool checkedInToday;
  final bool isLoading;
  final VoidCallback? onCheckIn;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.shieldAvailable,
    this.checkedInToday = false,
    this.isLoading = false,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text('\u{1F525}', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          '$currentStreak day streak',
          style: const TextStyle(color: AdminColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        if (shieldAvailable) ...<Widget>[
          const SizedBox(width: 12),
          const Text('\u{1F6E1}\u{FE0F}', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          const Text('Shield ready', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
        ],
        const Spacer(),
        if (onCheckIn != null)
          SizedBox(
            height: 32,
            child: FilledButton.tonal(
              onPressed: checkedInToday || isLoading ? null : onCheckIn,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: isLoading
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(checkedInToday ? 'Checked in' : 'Check in'),
            ),
          ),
      ],
    );
  }
}
