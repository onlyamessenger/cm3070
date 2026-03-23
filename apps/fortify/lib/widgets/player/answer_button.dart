import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

enum AnswerState { idle, correct, incorrect }

class AnswerButton extends StatelessWidget {
  final String text;
  final AnswerState answerState;
  final bool disabled;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.text,
    this.answerState = AnswerState.idle,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    switch (answerState) {
      case AnswerState.correct:
        borderColor = AdminColors.success;
        bgColor = const Color(0x2610B981);
      case AnswerState.incorrect:
        borderColor = AdminColors.error;
        bgColor = const Color(0x26EF4444);
      case AnswerState.idle:
        borderColor = AdminColors.surfaceBorder;
        bgColor = AdminColors.surfaceContainer;
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: answerState == AnswerState.idle ? 1 : 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: disabled && answerState == AnswerState.idle ? AdminColors.onSurfaceVariant : AdminColors.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
