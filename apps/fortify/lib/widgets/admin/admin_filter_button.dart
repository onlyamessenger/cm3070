import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int activeFilterCount;

  const AdminFilterButton({super.key, required this.onPressed, this.activeFilterCount = 0});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.filter_list, size: 18),
      label: Text(activeFilterCount > 0 ? 'Filter ($activeFilterCount)' : 'Filter'),
      style: OutlinedButton.styleFrom(
        foregroundColor: activeFilterCount > 0 ? AdminColors.primary : AdminColors.onSurfaceVariant,
        side: BorderSide(
          color: activeFilterCount > 0 ? AdminColors.primary.withValues(alpha: 0.3) : AdminColors.surfaceBorder,
        ),
      ),
    );
  }
}
