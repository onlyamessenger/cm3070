import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const StatCard({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}
