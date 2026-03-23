// apps/fortify/lib/pages/player/readiness/shelter_location_detail_page.dart
import 'package:flutter/material.dart';

import 'package:fortify/config/evacuation_routes_data.dart';
import 'package:fortify/config/shelter_locations_data.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class ShelterLocationDetailPage extends StatelessWidget {
  final int shelterIndex;

  const ShelterLocationDetailPage({super.key, required this.shelterIndex});

  @override
  Widget build(BuildContext context) {
    final int safeIndex = shelterIndex.clamp(0, shelterLocations.length - 1);
    final ShelterLocationData shelter = shelterLocations[safeIndex];

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.onSurface,
        title: Text(shelter.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          // Type chip
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(6)),
              child: Text(
                shelter.type,
                style: const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Summary card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.location_on_outlined, color: AdminColors.onSurfaceVariant, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(shelter.address, style: const TextStyle(color: AdminColors.onSurface, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(Icons.straighten, color: AdminColors.onSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      shelter.distance,
                      style: const TextStyle(color: AdminColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.people_outline, color: AdminColors.onSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text(shelter.capacity, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            shelter.description,
            style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Amenities
          const Text(
            'Amenities',
            style: TextStyle(color: AdminColors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...shelter.amenities.map((String amenity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_circle, color: AdminColors.success, size: 18),
                  const SizedBox(width: 10),
                  Text(amenity, style: const TextStyle(color: AdminColors.onSurface, fontSize: 14)),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Directions
          const Text(
            'Directions from home',
            style: TextStyle(color: AdminColors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...List<Widget>.generate(shelter.directions.length, (int i) {
            final RouteStep step = shelter.directions[i];
            final bool isLast = i == shelter.directions.length - 1;
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
