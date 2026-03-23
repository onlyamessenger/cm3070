import 'package:flutter/material.dart';

import 'package:fortify/config/evacuation_routes_data.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class EvacuationRouteDetailPage extends StatelessWidget {
  final int routeIndex;

  const EvacuationRouteDetailPage({super.key, required this.routeIndex});

  @override
  Widget build(BuildContext context) {
    final int safeIndex = routeIndex.clamp(0, evacuationRoutes.length - 1);
    final EvacuationRouteData route = evacuationRoutes[safeIndex];

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.onSurface,
        title: Text(route.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(6)),
              child: Text(
                route.disasterType,
                style: const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Destination', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        route.destination,
                        style: const TextStyle(color: AdminColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      route.totalDistance,
                      style: const TextStyle(color: AdminColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      route.estimatedTime,
                      style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            route.description,
            style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Turn-by-turn directions',
            style: TextStyle(color: AdminColors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...List<Widget>.generate(route.steps.length, (int i) {
            final RouteStep step = route.steps[i];
            final bool isLast = i == route.steps.length - 1;
            return _StepTile(stepNumber: i + 1, step: step, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int stepNumber;
  final RouteStep step;
  final bool isLast;

  const _StepTile({required this.stepNumber, required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Column(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: AdminColors.surfaceContainerHigh, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AdminColors.surfaceContainerHigh)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          step.instruction,
                          style: const TextStyle(color: AdminColors.onSurface, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          step.distance,
                          style: const TextStyle(
                            color: AdminColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step.note != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.warning_amber_rounded, color: AdminColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(step.note!, style: const TextStyle(color: AdminColors.warning, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
