import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class ActivityTile extends StatelessWidget {
  final ActivityLogEntry entry;

  const ActivityTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final String icon = _iconForSource(entry.sourceType);
    final String timeAgo = _formatTime(entry.created);
    final String xpText = '+${entry.xpAmount} XP';
    final String multiplierText = entry.multiplierApplied != null && entry.multiplierApplied! > 1.0
        ? ' (x${entry.multiplierApplied})'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.action,
                  style: const TextStyle(color: AdminColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(timeAgo, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '$xpText$multiplierText',
            style: const TextStyle(color: AdminColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static String _iconForSource(ActivitySourceType? type) {
    switch (type) {
      case ActivitySourceType.quest:
        return '\u2694\uFE0F';
      case ActivitySourceType.challenge:
        return '\u26A1';
      case ActivitySourceType.checkIn:
        return '\u2705';
      case ActivitySourceType.bonus:
        return '\u{1F381}';
      case null:
        return '\u{1F4AC}';
    }
  }

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatTime(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day} ${_months[date.month - 1]}';
  }
}
