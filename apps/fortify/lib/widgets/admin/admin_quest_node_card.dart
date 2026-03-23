import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

/// A single node card in the quest tree visualization.
///
/// Displays day label, narrative text preview, XP badge, and outcome badge.
/// XP-based glow intensity: higher XP → brighter BoxShadow.
/// "+" button on non-outcome nodes to add branches.
class AdminQuestNodeCard extends StatefulWidget {
  final QuestNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onAddBranch;

  const AdminQuestNodeCard({
    super.key,
    required this.node,
    this.isSelected = false,
    required this.onTap,
    this.onAddBranch,
  });

  static const double cardWidth = 140.0;
  static const double cardHeight = 72.0;

  @override
  State<AdminQuestNodeCard> createState() => _AdminQuestNodeCardState();
}

class _AdminQuestNodeCardState extends State<AdminQuestNodeCard> {
  bool _isHovered = false;

  bool get _isNegativeXp => widget.node.xpReward < 0;

  bool get _hasNegativeChoices => widget.node.choices.any((QuestChoice c) => c.xpReward < 0);

  /// Computes glow intensity from XP reward (0.0 to 1.0 range).
  /// Uses a logarithmic scale so low XP values still show some glow.
  double get _glowIntensity {
    final int absXp = widget.node.xpReward.abs();
    if (absXp == 0) return 0.1;
    return min(1.0, 0.2 + (log(absXp.toDouble()) / log(200)) * 0.8);
  }

  Color get _accentColor => _isNegativeXp ? AdminColors.error : AdminColors.primary;

  @override
  Widget build(BuildContext context) {
    final double glow = widget.isSelected ? 1.0 : _glowIntensity;
    final double nodeOpacity = (_glowIntensity + 0.3).clamp(0.5, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: SizedBox(
          width: AdminQuestNodeCard.cardWidth + (widget.node.isOutcome ? 0 : 24),
          height: AdminQuestNodeCard.cardHeight,
          child: Row(
            children: <Widget>[
              // The node card itself
              Opacity(
                opacity: nodeOpacity,
                child: Container(
                  width: AdminQuestNodeCard.cardWidth,
                  height: AdminQuestNodeCard.cardHeight,
                  decoration: BoxDecoration(
                    color: AdminColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _accentColor, width: widget.isSelected ? 2.0 : (_isHovered ? 1.5 : 1.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: _accentColor.withValues(alpha: glow * 0.4),
                        blurRadius: glow * 12,
                        spreadRadius: glow * 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Top row: day label + XP badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'DAY ${widget.node.day}',
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: _isNegativeXp
                                  ? AdminColors.error.withValues(alpha: 0.8)
                                  : AdminColors.primaryVariant,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${widget.node.xpReward} XP',
                              style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Narrative text preview
                      Expanded(
                        child: Text(
                          widget.node.text,
                          style: const TextStyle(color: AdminColors.onSurface, fontSize: 9.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Bottom badges row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (_hasNegativeChoices)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: AdminColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PENALTY',
                                style: TextStyle(color: AdminColors.error, fontSize: 6.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          if (widget.node.isOutcome)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AdminColors.primaryVariant.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OUTCOME',
                                style: TextStyle(
                                  color: AdminColors.primary,
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // "+" button for non-outcome nodes
              if (!widget.node.isOutcome)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: widget.onAddBranch,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AdminColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: _accentColor, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+',
                          style: TextStyle(color: _accentColor, fontSize: 14, fontWeight: FontWeight.w500, height: 1),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
