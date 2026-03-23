import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class ReadinessCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool unlocked;
  final String? hintText;
  final Widget? child;
  final VoidCallback? onTap;

  const ReadinessCard({
    super.key,
    required this.icon,
    required this.title,
    this.unlocked = false,
    this.hintText,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget card = Opacity(
      opacity: unlocked ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: unlocked ? const Border(left: BorderSide(color: AdminColors.primary, width: 3)) : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: AdminColors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                if (!unlocked) const Text('\u{1F512}', style: TextStyle(fontSize: 14)),
              ],
            ),
            if (!unlocked && hintText != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(hintText!, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
            ],
            if (unlocked && child != null) ...<Widget>[
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.only(left: 26), child: child!),
            ],
          ],
        ),
      ),
    );

    if (unlocked && onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
