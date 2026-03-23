import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminBulkAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const AdminBulkAction({required this.label, required this.icon, required this.onPressed, this.color});
}

class AdminBulkActionBar extends StatelessWidget {
  final int selectedCount;
  final List<AdminBulkAction> actions;
  final VoidCallback onClearSelection;

  const AdminBulkActionBar({
    super.key,
    required this.selectedCount,
    required this.actions,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: AdminColors.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: AdminColors.surfaceBorder)),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '$selectedCount selected',
            style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 16),
          ...actions.map((AdminBulkAction action) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: action.onPressed,
                icon: Icon(action.icon, size: 18),
                label: Text(action.label),
                style: TextButton.styleFrom(foregroundColor: action.color ?? AdminColors.onSurface),
              ),
            );
          }),
          const Spacer(),
          TextButton(
            onPressed: onClearSelection,
            child: const Text('Clear', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
