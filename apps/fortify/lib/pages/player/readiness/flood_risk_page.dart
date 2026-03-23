import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class FloodRiskPage extends StatelessWidget {
  const FloodRiskPage({super.key});

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
            Text('\u26A0\uFE0F', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Flood Risk Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your Local Flood Risk',
                  style: TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'This section will show personalised flood risk information for your area, '
                  'including hazard levels, historical flood data, and seasonal risk patterns.',
                  style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: '\u{1F30A}',
            title: 'Risk Level',
            description: 'Moderate - based on regional flood plain data for your area.',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: '\u{1F4C5}',
            title: 'Peak Season',
            description: 'October to March - summer rainfall brings the highest flood risk.',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: '\u{1F4DE}',
            title: 'Emergency Line',
            description: 'Disaster Management: 10177\nEmergency Services: 112',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.surfaceBorder),
            ),
            child: const Row(
              children: <Widget>[
                Text('\u{1F6A7}', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Live flood risk data and personalised maps are coming in a future update.',
                    style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _InfoCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(color: AdminColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
