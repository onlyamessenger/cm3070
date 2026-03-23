import 'package:flutter/material.dart';

import 'package:fortify/config/theme/admin_colors.dart';

class XpBar extends StatelessWidget {
  final double progress;
  final String? label;

  const XpBar({super.key, required this.progress, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  children: <Widget>[
                    Container(decoration: const BoxDecoration(color: AdminColors.surfaceContainer)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                      decoration: const BoxDecoration(
                        color: AdminColors.primary,
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: AdminColors.primaryGlow, blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (label != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(label!, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12)),
        ],
      ],
    );
  }
}
