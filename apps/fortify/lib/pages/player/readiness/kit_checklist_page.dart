import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/readiness_controller.dart';
import 'package:fortify/state/readiness_state.dart';
import 'package:fortify/widgets/player/kit_item_detail_sheet.dart';
import 'package:fortify/widgets/player/kit_item_tile.dart';

class KitChecklistPage extends StatelessWidget {
  const KitChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.onSurface,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('\u{1F392}', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Emergency Kit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<ReadinessState>(
        builder: (BuildContext context, ReadinessState state, Widget? _) {
          final List<KitItem> items = state.kitItems;
          final int checked = state.kitItemsChecked;
          final int total = state.kitItemsTotal;
          final double progress = state.kitProgress;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: <Widget>[
              const Text(
                'Check off items as you gather your emergency supplies.',
                style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$checked of $total items ready',
                            style: const TextStyle(
                              color: AdminColors.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(progress * 100).round()}% complete',
                            style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CustomPaint(
                        painter: _MiniRingPainter(progress: progress),
                        child: Center(
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: AdminColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((KitItem item) {
                return KitItemTile(item: item, onTap: () => _showDetail(context, item));
              }),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, KitItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return KitItemDetailSheet(item: item, onToggle: () => Inject.get<ReadinessController>().toggleKitItem(item));
      },
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;

  _MiniRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 4;
    final Rect rect = Offset.zero & size;
    final Rect deflated = rect.deflate(strokeWidth / 2);

    final Paint trackPaint = Paint()
      ..color = AdminColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint fillPaint = Paint()
      ..color = AdminColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(deflated, -pi / 2, 2 * pi, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(deflated, -pi / 2, 2 * pi * progress.clamp(0.0, 1.0), false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_MiniRingPainter oldDelegate) => oldDelegate.progress != progress;
}
