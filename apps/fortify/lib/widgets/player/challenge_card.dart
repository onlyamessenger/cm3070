import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final PlayerChallengeProgress? progress;
  final VoidCallback? onTap;

  const ChallengeCard({super.key, required this.challenge, this.progress, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = progress?.isCompleted ?? false;
    final bool isInProgress = progress != null && !isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted ? AdminColors.success : AdminColors.primaryOverlay),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    challenge.type.displayName,
                    style: const TextStyle(color: AdminColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    challenge.difficulty.displayName,
                    style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 11),
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: AdminColors.success, size: 20)
                else
                  Text(
                    '${challenge.xpReward} XP',
                    style: const TextStyle(color: AdminColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              challenge.title,
              style: const TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.description,
              style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isInProgress) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'In progress - Question ${progress!.currentQuestionIndex + 1}',
                style: const TextStyle(color: AdminColors.warning, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
