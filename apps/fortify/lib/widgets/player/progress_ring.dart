import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final String label;
  final String sublabel;

  const ProgressRing({super.key, required this.progress, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _RingPainter(progress: progress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(color: AdminColors.onSurface, fontSize: 28, fontWeight: FontWeight.w700),
              ),
              Text(
                sublabel,
                style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 6;
    final Rect rect = Offset.zero & size;
    final Rect deflated = rect.deflate(strokeWidth / 2);

    final Paint trackPaint = Paint()
      ..color = AdminColors.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint fillPaint = Paint()
      ..color = AdminColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(deflated, -pi / 2, 2 * pi, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(deflated, -pi / 2, 2 * pi * progress.clamp(0.0, 1.0), false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
