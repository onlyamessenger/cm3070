import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminStatusBadge extends StatelessWidget {
  final bool isPublished;

  const AdminStatusBadge({super.key, required this.isPublished});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPublished
                ? AdminColors.success.withValues(alpha: 0.12)
                : AdminColors.onSurfaceVariant.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPublished
                  ? AdminColors.success.withValues(alpha: 0.3)
                  : AdminColors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            isPublished ? 'Published' : 'Draft',
            style: TextStyle(
              color: isPublished ? AdminColors.success : AdminColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
