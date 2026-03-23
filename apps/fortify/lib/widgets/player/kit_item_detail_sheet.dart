import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class KitItemDetailSheet extends StatelessWidget {
  final KitItem item;
  final VoidCallback onToggle;

  const KitItemDetailSheet({super.key, required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: AdminColors.onSurfaceVariant, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: item.isChecked ? AdminColors.success : Colors.transparent,
                  border: item.isChecked ? null : Border.all(color: AdminColors.onSurfaceVariant, width: 2),
                ),
                child: item.isChecked ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            const Divider(color: AdminColors.surfaceContainer, height: 1),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.description,
                style: const TextStyle(color: AdminColors.onSurface, fontSize: 14, height: 1.7),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: item.isChecked
                ? OutlinedButton(
                    onPressed: () {
                      onToggle();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.onSurface,
                      side: const BorderSide(color: AdminColors.surfaceBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Mark as Not Ready', style: TextStyle(fontWeight: FontWeight.w600)),
                  )
                : ElevatedButton(
                    onPressed: () {
                      onToggle();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Mark as Ready', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
          ),
        ],
      ),
    );
  }
}
