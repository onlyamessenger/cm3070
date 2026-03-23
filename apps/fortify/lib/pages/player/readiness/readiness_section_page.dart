import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:fortify/config/readiness_metadata.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class ReadinessSectionPage extends StatelessWidget {
  final String sectionType;

  const ReadinessSectionPage({super.key, required this.sectionType});

  @override
  Widget build(BuildContext context) {
    final ReadinessSectionType type = ReadinessSectionType.fromString(sectionType);
    final SectionMeta meta = sectionMetadata[type]!;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.onSurface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(meta.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(meta.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(meta.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              meta.title,
              style: const TextStyle(color: AdminColors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Coming soon', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
