import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) displayName;
  final ValueChanged<T?> onChanged;

  const AdminDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.displayName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(value: item, child: Text(displayName(item)));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        dropdownColor: AdminColors.surfaceContainerHigh,
        style: const TextStyle(color: AdminColors.onSurface),
      ),
    );
  }
}
