import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class LevelBadge extends StatelessWidget {
  final String title;

  const LevelBadge({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[AdminColors.warning, Color(0xFFFF8C42)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
