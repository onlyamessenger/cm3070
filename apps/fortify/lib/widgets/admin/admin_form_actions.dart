import 'package:flutter/material.dart';
import 'package:fortify/widgets/admin/admin_button.dart';

class AdminFormActions extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveLabel;
  final bool isLoading;

  const AdminFormActions({super.key, this.onSave, this.onCancel, this.saveLabel = 'Save', this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          AdminButton(label: 'Cancel', isPrimary: false, onPressed: onCancel ?? () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
          AdminButton(
            label: isLoading ? 'Saving...' : saveLabel,
            onPressed: isLoading ? null : onSave,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
