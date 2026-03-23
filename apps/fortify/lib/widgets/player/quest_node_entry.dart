import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class QuestNodeEntry extends StatelessWidget {
  final QuestNode node;
  final String? chosenLabel;

  const QuestNodeEntry({super.key, required this.node, this.chosenLabel});

  @override
  Widget build(BuildContext context) {
    final bool isPast = chosenLabel != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPast ? AdminColors.surfaceContainer : AdminColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isPast ? AdminColors.onSurfaceVariant : AdminColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(4)),
            child: Text(
              'Day ${node.day}',
              style: const TextStyle(color: AdminColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            node.text,
            style: TextStyle(
              color: isPast ? AdminColors.onSurfaceVariant : AdminColors.onSurface,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (chosenLabel != null) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Icon(Icons.arrow_forward, color: AdminColors.primary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    chosenLabel!,
                    style: const TextStyle(color: AdminColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
