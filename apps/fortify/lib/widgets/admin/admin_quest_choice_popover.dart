import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

/// Popover menu shown when the "+" button is tapped on a quest node.
///
/// Lists unconnected choices (nextNodeId is empty) for the admin to select
/// which choice to branch from, plus an "Add new choice" option.
class AdminQuestChoicePopover {
  /// Shows the popover and returns the selected action.
  ///
  /// Returns:
  /// - A [QuestChoice] if the admin selected an unconnected choice to connect
  /// - `'new'` if the admin chose "Add new choice"
  /// - `null` if cancelled
  static Future<Object?> show(BuildContext context, {required QuestNode node, required RelativeRect position}) {
    final List<QuestChoice> unconnected = node.choices.where((QuestChoice c) => c.nextNodeId.isEmpty).toList();

    return showMenu<Object>(
      context: context,
      position: position,
      color: AdminColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: <PopupMenuEntry<Object>>[
        // Header
        const PopupMenuItem<Object>(
          enabled: false,
          height: 32,
          child: Text(
            'Connect to choice:',
            style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),

        // Unconnected choices
        ...unconnected.map((QuestChoice choice) {
          return PopupMenuItem<Object>(
            value: choice,
            child: Row(
              children: <Widget>[
                const Icon(Icons.radio_button_unchecked, size: 14, color: AdminColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${choice.label}"',
                    style: const TextStyle(color: AdminColors.onSurface, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),

        // Connected choices (greyed out)
        ...node.choices.where((QuestChoice c) => c.nextNodeId.isNotEmpty).map((QuestChoice choice) {
          return PopupMenuItem<Object>(
            enabled: false,
            child: Row(
              children: <Widget>[
                const Icon(Icons.check_circle, size: 14, color: AdminColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${choice.label}"',
                    style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),

        const PopupMenuDivider(),

        // Add new choice option
        const PopupMenuItem<Object>(
          value: 'new',
          child: Row(
            children: <Widget>[
              Icon(Icons.add, size: 14, color: AdminColors.primary),
              SizedBox(width: 8),
              Text('Add new choice', style: TextStyle(color: AdminColors.primary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
