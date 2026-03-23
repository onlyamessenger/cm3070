import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/readiness_metadata.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class UnlockSectionModal extends StatelessWidget {
  final String sectionType;
  final VoidCallback onViewDashboard;
  final VoidCallback onKeepPlaying;

  const UnlockSectionModal({
    super.key,
    required this.sectionType,
    required this.onViewDashboard,
    required this.onKeepPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final ReadinessSectionType type = ReadinessSectionType.fromString(sectionType);
    final SectionMeta meta = sectionMetadata[type]!;

    return GestureDetector(
      onTap: onKeepPlaying,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AdminColors.primaryTint,
                      border: Border.all(color: AdminColors.primaryGlow, width: 2),
                      boxShadow: const <BoxShadow>[BoxShadow(color: AdminColors.primaryOverlay, blurRadius: 24)],
                    ),
                    child: Center(child: Text(meta.icon, style: const TextStyle(fontSize: 36))),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'UNLOCKED',
                    style: TextStyle(
                      color: AdminColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.title,
                    style: const TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.unlockDescription,
                    style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        foregroundColor: AdminColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onKeepPlaying,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.onSurface,
                        side: const BorderSide(color: AdminColors.surfaceBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Keep Playing', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
