import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminDataCard<T> extends StatelessWidget {
  final T item;
  final Widget Function(T item) builder;
  final VoidCallback? onTap;
  final bool selectable;
  final bool isSelected;
  final VoidCallback? onSelect;

  const AdminDataCard({
    super.key,
    required this.item,
    required this.builder,
    this.onTap,
    this.selectable = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryOverlay : AdminColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AdminColors.primary : AdminColors.surfaceBorderSubtle),
        ),
        child: Row(
          children: <Widget>[
            if (selectable) ...<Widget>[
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelect?.call(),
                activeColor: AdminColors.primary,
                side: const BorderSide(color: AdminColors.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(child: builder(item)),
          ],
        ),
      ),
    );
  }
}
