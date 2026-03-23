import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class KitItemTile extends StatelessWidget {
  final KitItem item;
  final VoidCallback onTap;

  const KitItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AdminColors.surfaceContainer)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: item.isChecked ? AdminColors.success : Colors.transparent,
                border: item.isChecked ? null : Border.all(color: AdminColors.onSurfaceVariant, width: 2),
              ),
              child: item.isChecked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.itemName,
                    style: TextStyle(
                      color: item.isChecked ? AdminColors.onSurfaceVariant : AdminColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      item.description.length > 60 ? '${item.description.substring(0, 60)}...' : item.description,
                      style: TextStyle(
                        color: item.isChecked ? const Color(0xFF4B5563) : AdminColors.onSurfaceVariant,
                        fontSize: 12,
                        decoration: item.isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
