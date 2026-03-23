import 'dart:collection';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/widgets/admin/admin_quest_choice_popover.dart';
import 'package:fortify/widgets/admin/admin_quest_node_card.dart';
import 'package:fortify/widgets/admin/admin_quest_node_modal.dart';

/// Positioned node for rendering in the tree layout.
class _NodePosition {
  final QuestNode node;
  final double x;
  final double y;

  const _NodePosition({required this.node, required this.x, required this.y});
}

/// Interactive left-to-right quest node tree visualization.
///
/// Renders nodes as positioned Flutter widgets (AdminQuestNodeCard) on top of
/// CustomPaint bezier connectors, all wrapped in InteractiveViewer for pan/zoom.
///
/// Layout algorithm:
/// 1. Build adjacency map from choices
/// 2. BFS from startNodeId to position nodes left-to-right by depth
/// 3. Orphaned nodes shown in a "Disconnected" section below
class AdminQuestNodeTree extends StatefulWidget {
  final List<QuestNode> nodes;
  final String questId;
  final String startNodeId;
  final void Function(List<QuestNode>, String startNodeId) onChanged;

  const AdminQuestNodeTree({
    super.key,
    required this.nodes,
    required this.questId,
    required this.startNodeId,
    required this.onChanged,
  });

  @override
  State<AdminQuestNodeTree> createState() => _AdminQuestNodeTreeState();
}

class _AdminQuestNodeTreeState extends State<AdminQuestNodeTree> {
  static const double _horizontalSpacing = 200.0;
  static const double _verticalSpacing = 90.0;
  static const double _padding = 40.0;

  int _tempIdCounter = 0;

  String _generateTempId() {
    _tempIdCounter++;
    return 'temp_$_tempIdCounter';
  }

  /// Computes node positions using breadth-first traversal from the start node.
  ///
  /// Returns positioned nodes and the total canvas size needed.
  ({List<_NodePosition> positions, double width, double height}) _computeLayout() {
    if (widget.nodes.isEmpty) {
      return (positions: <_NodePosition>[], width: 300, height: 200);
    }

    final Map<String, QuestNode> nodeMap = <String, QuestNode>{for (final QuestNode n in widget.nodes) n.id: n};

    // ── Step 1: BFS to determine depth of each node ──
    final Map<String, int> depthMap = <String, int>{};
    final Map<int, List<String>> depthBuckets = <int, List<String>>{};
    final Queue<String> queue = Queue<String>();
    final Set<String> visited = <String>{};

    if (widget.startNodeId.isNotEmpty && nodeMap.containsKey(widget.startNodeId)) {
      queue.add(widget.startNodeId);
      depthMap[widget.startNodeId] = 0;
    }

    while (queue.isNotEmpty) {
      final String currentId = queue.removeFirst();
      if (visited.contains(currentId)) continue;
      visited.add(currentId);

      final int depth = depthMap[currentId] ?? 0;
      depthBuckets.putIfAbsent(depth, () => <String>[]).add(currentId);

      final QuestNode? node = nodeMap[currentId];
      if (node == null) continue;

      for (final QuestChoice choice in node.choices) {
        if (choice.nextNodeId.isNotEmpty && !visited.contains(choice.nextNodeId)) {
          depthMap[choice.nextNodeId] = depth + 1;
          queue.add(choice.nextNodeId);
        }
      }
    }

    // ── Step 2: Position nodes by depth (x) and sibling index (y) ──
    final List<_NodePosition> positions = <_NodePosition>[];
    double maxX = 0;
    double maxY = 0;

    for (final MapEntry<int, List<String>> entry in depthBuckets.entries) {
      final int depth = entry.key;
      final List<String> nodesAtDepth = entry.value;
      final double x = _padding + depth * _horizontalSpacing;

      for (int i = 0; i < nodesAtDepth.length; i++) {
        final QuestNode? node = nodeMap[nodesAtDepth[i]];
        if (node == null) continue;

        final double y = _padding + i * _verticalSpacing;
        positions.add(_NodePosition(node: node, x: x, y: y));
        maxX = max(maxX, x + AdminQuestNodeCard.cardWidth + 40);
        maxY = max(maxY, y + AdminQuestNodeCard.cardHeight + 20);
      }
    }

    // ── Step 3: Add orphaned nodes (not reachable from start) ──
    final List<QuestNode> orphaned = widget.nodes.where((QuestNode n) => !visited.contains(n.id)).toList();
    if (orphaned.isNotEmpty) {
      final double orphanStartY = maxY + 40;
      for (int i = 0; i < orphaned.length; i++) {
        final double y = orphanStartY + i * _verticalSpacing;
        positions.add(_NodePosition(node: orphaned[i], x: _padding, y: y));
        maxY = max(maxY, y + AdminQuestNodeCard.cardHeight + 20);
      }
    }

    return (positions: positions, width: max(maxX, 300) + _padding, height: max(maxY, 200) + _padding);
  }

  Future<void> _onNodeTap(QuestNode node) async {
    final QuestNode? result = await AdminQuestNodeModal.show(
      context,
      node: node,
      questId: widget.questId,
      allNodes: widget.nodes,
    );

    if (result != null) {
      final List<QuestNode> updated = widget.nodes.map((QuestNode n) => n.id == result.id ? result : n).toList();
      widget.onChanged(updated, widget.startNodeId);
    }
  }

  Future<void> _onAddBranch(QuestNode parentNode, BuildContext cardContext) async {
    // Show the choice popover
    final RenderBox box = cardContext.findRenderObject()! as RenderBox;
    final Offset offset = box.localToGlobal(Offset(box.size.width, box.size.height / 2));
    final RelativeRect position = RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy);

    final Object? result = await AdminQuestChoicePopover.show(context, node: parentNode, position: position);

    if (result == null) return;

    if (result == 'new') {
      // "Add new choice" - create a new node and add a choice pointing to it
      await _addNewChoiceAndNode(parentNode);
    } else if (result is QuestChoice) {
      // Selected an unconnected choice - create a new node and connect it
      await _connectChoiceToNewNode(parentNode, result);
    }
  }

  /// Creates a new node via modal and adds a new choice on the parent pointing to it.
  Future<void> _addNewChoiceAndNode(QuestNode parentNode) async {
    final String tempId = _generateTempId();

    final QuestNode? newNode = await AdminQuestNodeModal.show(context, questId: widget.questId, allNodes: widget.nodes);

    if (newNode == null) return;

    // Assign the temp ID to the new node
    final QuestNode nodeWithId = newNode.copyWith(id: tempId);

    // Add a new choice to the parent pointing to this node
    // The label comes from a simple dialog
    final String? label = await _askChoiceLabel();
    if (label == null || label.isEmpty) return;

    final QuestChoice newChoice = QuestChoice(label: label, nextNodeId: tempId);
    final QuestNode updatedParent = parentNode.copyWith(choices: <QuestChoice>[...parentNode.choices, newChoice]);

    final List<QuestNode> updated = widget.nodes.map((QuestNode n) {
      return n.id == parentNode.id ? updatedParent : n;
    }).toList()..add(nodeWithId);

    widget.onChanged(updated, widget.startNodeId);
  }

  /// Creates a new node via modal and connects an existing unconnected choice to it.
  Future<void> _connectChoiceToNewNode(QuestNode parentNode, QuestChoice choice) async {
    final String tempId = _generateTempId();

    final QuestNode? newNode = await AdminQuestNodeModal.show(context, questId: widget.questId, allNodes: widget.nodes);

    if (newNode == null) return;

    final QuestNode nodeWithId = newNode.copyWith(id: tempId);

    // Update the choice's nextNodeId to point to the new node
    final List<QuestChoice> updatedChoices = parentNode.choices.map((QuestChoice c) {
      if (c.label == choice.label && c.nextNodeId.isEmpty) {
        return c.copyWith(nextNodeId: tempId);
      }
      return c;
    }).toList();

    final QuestNode updatedParent = parentNode.copyWith(choices: updatedChoices);

    final List<QuestNode> updated = widget.nodes.map((QuestNode n) {
      return n.id == parentNode.id ? updatedParent : n;
    }).toList()..add(nodeWithId);

    widget.onChanged(updated, widget.startNodeId);
  }

  /// Simple dialog to ask for a choice label.
  Future<String?> _askChoiceLabel() async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AdminColors.surface,
          title: const Text('Choice Label', style: TextStyle(color: AdminColors.onSurface, fontSize: 16)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: const InputDecoration(hintText: 'e.g. "Evacuate immediately"'),
            onSubmitted: (String value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('OK')),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _addStartNode() async {
    final String tempId = _generateTempId();

    final QuestNode? newNode = await AdminQuestNodeModal.show(context, questId: widget.questId, allNodes: widget.nodes);

    if (newNode == null) return;

    final QuestNode nodeWithId = newNode.copyWith(id: tempId);
    widget.onChanged(<QuestNode>[...widget.nodes, nodeWithId], tempId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(height: 32),
        _buildHeader(),
        const SizedBox(height: 12),
        if (widget.nodes.isEmpty) _buildEmptyState() else _buildTree(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        const Text(
          'Quest Nodes',
          style: TextStyle(color: AdminColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (widget.nodes.isNotEmpty) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(10)),
            child: Text(
              widget.nodes.length.toString(),
              style: const TextStyle(color: AdminColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: AdminColors.surfaceBorderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'No nodes yet. Click + to add the start node.',
              style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _addStartNode,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Start Node'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree() {
    final ({List<_NodePosition> positions, double width, double height}) layout = _computeLayout();

    // Build a position lookup for drawing connectors
    final Map<String, Offset> positionMap = <String, Offset>{
      for (final _NodePosition p in layout.positions)
        p.node.id: Offset(p.x + AdminQuestNodeCard.cardWidth / 2, p.y + AdminQuestNodeCard.cardHeight / 2),
    };

    return SizedBox(
      height: max(layout.height, 300),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.3,
        maxScale: 2.0,
        child: SizedBox(
          width: layout.width,
          height: layout.height,
          child: Stack(
            children: <Widget>[
              // Layer 1: Connector lines drawn by CustomPaint
              CustomPaint(
                size: Size(layout.width, layout.height),
                painter: _ConnectorPainter(nodes: widget.nodes, positionMap: positionMap),
              ),

              // Layer 2: Positioned node cards
              ...layout.positions.map((_NodePosition pos) {
                return Positioned(
                  left: pos.x,
                  top: pos.y,
                  child: Builder(
                    builder: (BuildContext cardContext) {
                      return AdminQuestNodeCard(
                        node: pos.node,
                        isSelected: false,
                        onTap: () => _onNodeTap(pos.node),
                        onAddBranch: pos.node.isOutcome ? null : () => _onAddBranch(pos.node, cardContext),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter that draws bezier curves between connected nodes
/// and renders choice labels along the connectors.
class _ConnectorPainter extends CustomPainter {
  final List<QuestNode> nodes;
  final Map<String, Offset> positionMap;

  _ConnectorPainter({required this.nodes, required this.positionMap});

  @override
  void paint(Canvas canvas, Size size) {
    for (final QuestNode node in nodes) {
      final Offset? start = positionMap[node.id];
      if (start == null) continue;

      // Draw from the right edge of the parent to the left edge of each child
      final Offset startPoint = Offset(start.dx + AdminQuestNodeCard.cardWidth / 2, start.dy);

      for (final QuestChoice choice in node.choices) {
        if (choice.nextNodeId.isEmpty) continue;

        final Offset? end = positionMap[choice.nextNodeId];
        if (end == null) continue;

        final bool isNegative = choice.xpReward < 0;
        final Color lineColor = isNegative
            ? AdminColors.error.withValues(alpha: 0.5)
            : AdminColors.primary.withValues(alpha: 0.3);

        final Paint linePaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isNegative ? 1.5 : 1.0;

        final Offset endPoint = Offset(end.dx - AdminQuestNodeCard.cardWidth / 2, end.dy);

        // Draw bezier curve
        final double controlOffset = (endPoint.dx - startPoint.dx) * 0.4;
        final Path path = Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..cubicTo(
            startPoint.dx + controlOffset,
            startPoint.dy,
            endPoint.dx - controlOffset,
            endPoint.dy,
            endPoint.dx,
            endPoint.dy,
          );

        canvas.drawPath(path, linePaint);

        // Draw choice label at the midpoint of the connector
        final Offset midpoint = Offset((startPoint.dx + endPoint.dx) / 2, (startPoint.dy + endPoint.dy) / 2);
        final String xpSuffix = choice.xpReward != 0 ? ' (${choice.xpReward} XP)' : '';
        _drawChoiceLabel(canvas, midpoint, '"${choice.label}"$xpSuffix', isNegative: isNegative);
      }
    }
  }

  void _drawChoiceLabel(Canvas canvas, Offset position, String label, {bool isNegative = false}) {
    final Color accentColor = isNegative ? AdminColors.error : AdminColors.primary;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: accentColor.withValues(alpha: 0.7), fontSize: 7),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw background pill
    final double padding = 4;
    final Rect bgRect = Rect.fromCenter(
      center: position,
      width: textPainter.width + padding * 2,
      height: textPainter.height + padding,
    );
    final Paint bgPaint = Paint()..color = AdminColors.surface;
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), bgPaint);

    // Draw border
    final Paint borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), borderPaint);

    // Draw text
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.positionMap != positionMap;
  }
}
