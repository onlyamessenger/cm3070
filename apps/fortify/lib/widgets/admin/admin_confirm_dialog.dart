import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const AdminConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AdminConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: AdminColors.surfaceContainer.withValues(alpha: 0.95),
        title: Text(title, style: const TextStyle(color: AdminColors.onSurface)),
        content: Text(message, style: const TextStyle(color: AdminColors.onSurfaceVariant)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
