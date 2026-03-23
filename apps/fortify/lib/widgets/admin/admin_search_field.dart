import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const AdminSearchField({super.key, this.hintText = 'Search...', required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AdminColors.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: AdminColors.onSurfaceVariant),
        filled: true,
        fillColor: AdminColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.surfaceBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
