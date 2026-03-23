import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class QuestChoiceButton extends StatelessWidget {
  final QuestChoice choice;
  final VoidCallback? onTap;

  const QuestChoiceButton({super.key, required this.choice, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminColors.primary),
        ),
        child: Text(choice.label, style: const TextStyle(color: AdminColors.onSurface, fontSize: 15)),
      ),
    );
  }
}
