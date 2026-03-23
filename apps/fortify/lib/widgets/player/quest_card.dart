import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final PlayerQuestProgress? progress;
  final bool isLocked;
  final VoidCallback? onTap;

  const QuestCard({super.key, required this.quest, this.progress, this.isLocked = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = progress?.isCompleted ?? false;
    final bool isInProgress = progress != null && !isCompleted;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
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
                    decoration: BoxDecoration(
                      color: AdminColors.primaryOverlay,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      quest.disasterType.displayName,
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
                      quest.difficulty.displayName,
                      style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 11),
                    ),
                  ),
                  const Spacer(),
                  if (isLocked)
                    const Icon(Icons.lock, color: AdminColors.onSurfaceVariant, size: 18)
                  else if (isCompleted)
                    const Icon(Icons.check_circle, color: AdminColors.success, size: 20)
                  else
                    Text(
                      '${quest.totalDays} Days',
                      style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                quest.title,
                style: const TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                quest.description,
                style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isInProgress) ...<Widget>[
                const SizedBox(height: 8),
                const Text(
                  'In progress',
                  style: TextStyle(color: AdminColors.warning, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
