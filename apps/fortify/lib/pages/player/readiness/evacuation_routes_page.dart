import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fortify/config/evacuation_routes_data.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class EvacuationRoutesPage extends StatelessWidget {
  const EvacuationRoutesPage({super.key});

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
            Text('\u{1F6AA}', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Evacuation Routes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.home_outlined, color: AdminColors.onSurfaceVariant, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(homeAddress, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(evacuationRoutes.length, (int index) {
            final EvacuationRouteData route = evacuationRoutes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RouteCard(route: route, onTap: () => context.push('/readiness/evacuation-routes/$index')),
            );
          }),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final EvacuationRouteData route;
  final VoidCallback onTap;

  const _RouteCard({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    route.disasterType,
                    style: const TextStyle(color: AdminColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AdminColors.onSurfaceVariant, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              route.name,
              style: const TextStyle(color: AdminColors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(route.destination, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.straighten, color: AdminColors.onSurfaceVariant, size: 14),
                const SizedBox(width: 4),
                Text(route.totalDistance, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, color: AdminColors.onSurfaceVariant, size: 14),
                const SizedBox(width: 4),
                Text(route.estimatedTime, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
