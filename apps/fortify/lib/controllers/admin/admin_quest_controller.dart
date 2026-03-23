import 'dart:collection';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:core/core.dart';

import 'package:fortify/state/admin/admin_quest_state.dart';

/// Orchestrates Quest CRUD side effects, including embedded quest node management.
class AdminQuestController {
  final DataSource<Quest> _dataSource;
  final DataSource<QuestNode> _nodeDataSource;
  final AdminQuestState _state;
  final Functions _functions;

  AdminQuestController({
    required DataSource<Quest> dataSource,
    required DataSource<QuestNode> nodeDataSource,
    required AdminQuestState state,
    required Functions functions,
  }) : _dataSource = dataSource,
       _nodeDataSource = nodeDataSource,
       _state = state,
       _functions = functions;

  Future<void> loadItems() async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Quest> results = await _dataSource.readItems();
      _state.setItems(results);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> createItem(Quest quest) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Quest created = await _dataSource.createItem(quest);
      _state.addItem(created);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> updateItem(Quest quest) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Quest updated = await _dataSource.updateItem(quest);
      _state.editItem(updated);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> removeItem(Quest quest) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      await _dataSource.deleteItem(quest);
      _state.deleteItem(quest);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> publishItem(Quest quest) async {
    await updateItem(quest.copyWith(isPublished: true));
  }

  Future<void> bulkDelete(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Quest> items = _state.items.where((Quest q) => ids.contains(q.id)).toList();
      for (final Quest item in items) {
        await _dataSource.deleteItem(item);
        _state.deleteItem(item);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> bulkPublish(Set<String> ids) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<Quest> items = _state.items.where((Quest q) => ids.contains(q.id) && !q.isPublished).toList();
      for (final Quest item in items) {
        final Quest updated = await _dataSource.updateItem(item.copyWith(isPublished: true));
        _state.editItem(updated);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _state.setFilters(filters);
    await loadItems();
  }

  Future<void> generateQuests({
    required int count,
    required String model,
    required String difficulty,
    required String disasterType,
    required String totalDays,
    required int maxDepth,
    required int maxBranches,
    String? guidance,
  }) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final Execution result = await _functions.createExecution(
        functionId: 'admin',
        path: '/generate-quests',
        body: jsonEncode(<String, dynamic>{
          'count': count,
          'model': model,
          'difficulty': difficulty,
          'disasterType': disasterType,
          'totalDays': totalDays,
          'maxDepth': maxDepth,
          'maxBranches': maxBranches,
          'guidance': guidance,
        }),
        method: ExecutionMethod.pOST,
      );

      final Map<String, dynamic> response = jsonDecode(result.responseBody) as Map<String, dynamic>;

      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Generation failed');
      }

      await loadItems();
    } on Exception catch (e) {
      _state.setError(e.toString());
      rethrow;
    } finally {
      _state.setLoading(false);
    }
  }

  void search(String query) {
    _state.setSearchQuery(query);
  }

  // ── Node Management ──

  /// Loads all quest nodes belonging to the given quest.
  Future<List<QuestNode>> loadNodesForQuest(String questId) async {
    return _nodeDataSource.readItemsWhere('questId', questId);
  }

  /// Saves the quest and its nodes together.
  ///
  /// For new quests: saves the quest with startNodeId='', then saves nodes
  /// breadth-first with temp ID resolution, then patches the quest with the
  /// real startNodeId.
  ///
  /// For existing quests: diffs nodes against the original list, deletes
  /// removed nodes deepest-first, creates new nodes breadth-first, updates
  /// changed nodes, then patches startNodeId if needed.
  Future<void> saveWithNodes({
    required Quest quest,
    required List<QuestNode> currentNodes,
    required List<QuestNode> originalNodes,
    required String startNodeId,
    required bool isNew,
  }) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      // ── Step 1: Save the quest ──
      // For new quests, startNodeId is a temp ID - save with empty string
      // placeholder first, then patch after nodes are saved.
      final Quest questToSave = isNew ? quest.copyWith(startNodeId: '') : quest.copyWith(startNodeId: startNodeId);

      final Quest savedQuest;
      if (isNew) {
        savedQuest = await _dataSource.createItem(questToSave);
        _state.addItem(savedQuest);
      } else {
        savedQuest = await _dataSource.updateItem(questToSave);
        _state.editItem(savedQuest);
      }

      // ── Step 2: Assign questId to all nodes ──
      List<QuestNode> nodesWithQuestId = currentNodes.map((QuestNode n) => n.copyWith(questId: savedQuest.id)).toList();

      // ── Step 3: Save nodes with temp ID resolution ──
      final Map<String, String> tempToRealIds;
      if (isNew) {
        // All nodes are new - save breadth-first
        tempToRealIds = await _saveNodesBreadthFirst(nodesWithQuestId, startNodeId);
      } else {
        // Diff against original - create, update, delete as needed
        tempToRealIds = await _saveNodesDiff(nodesWithQuestId, originalNodes, startNodeId);
      }

      // ── Step 4: Patch the quest with the real startNodeId ──
      // If startNodeId was a temp ID, resolve it to the real one
      final String realStartNodeId = tempToRealIds[startNodeId] ?? startNodeId;
      if (realStartNodeId != savedQuest.startNodeId) {
        final Quest patched = await _dataSource.updateItem(savedQuest.copyWith(startNodeId: realStartNodeId));
        _state.editItem(patched);
      }
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  /// Saves all nodes breadth-first from the start node, resolving temp IDs
  /// as each node is persisted.
  ///
  /// Returns a map of temp ID → real AppWrite ID for all created nodes.
  ///
  /// Algorithm:
  /// 1. Start with the root node (matching startNodeId) in a queue
  /// 2. For each node in the queue:
  ///    a. Save it to AppWrite → receive real ID
  ///    b. Record the temp→real mapping
  ///    c. Replace this temp ID in all remaining nodes' choice.nextNodeId references
  ///    d. Add this node's children (by nextNodeId) to the queue
  /// 3. Repeat until the queue is empty
  Future<Map<String, String>> _saveNodesBreadthFirst(List<QuestNode> nodes, String startNodeId) async {
    final Map<String, String> tempToReal = <String, String>{};

    // Build a mutable working copy for traversal
    final List<QuestNode> workingNodes = nodes.map((QuestNode n) => n.copyWith()).toList();

    // ── Phase 1: Create all nodes (choices still have temp IDs) ──
    // BFS traversal to create nodes level by level. At this stage, choices
    // in saved documents still reference temp IDs - that's expected. We fix
    // them in Phase 2 after all real IDs are known.
    final Queue<String> queue = Queue<String>();
    queue.add(startNodeId);
    final Set<String> visited = <String>{};

    while (queue.isNotEmpty) {
      final String currentTempId = queue.removeFirst();
      if (visited.contains(currentTempId)) continue;
      visited.add(currentTempId);

      // Find the node with this temp ID
      final int nodeIndex = workingNodes.indexWhere((QuestNode n) => n.id == currentTempId);
      if (nodeIndex < 0) continue;

      final QuestNode node = workingNodes[nodeIndex];
      final String originalId = node.id;

      // Clear the temp ID so AppWrite generates a real one via ID.unique()
      final QuestNode nodeToSave = node.copyWith(id: '');
      final QuestNode saved = await _nodeDataSource.createItem(nodeToSave);

      // Record temp → real ID mapping
      tempToReal[originalId] = saved.id;

      // Enqueue child nodes (referenced by this node's choices)
      for (final QuestChoice choice in node.choices) {
        if (choice.nextNodeId.isNotEmpty && !visited.contains(choice.nextNodeId)) {
          queue.add(choice.nextNodeId);
        }
      }
    }

    // Create any orphaned nodes not reachable from the start node
    for (final QuestNode node in workingNodes) {
      if (!visited.contains(node.id) && !tempToReal.containsKey(node.id)) {
        final String orphanOriginalId = node.id;
        final QuestNode orphanToSave = node.copyWith(id: '');
        final QuestNode saved = await _nodeDataSource.createItem(orphanToSave);
        tempToReal[orphanOriginalId] = saved.id;
      }
    }

    // ── Phase 2: Update all saved nodes to resolve temp IDs in choices ──
    // Now that every node has a real ID, go through each saved node and
    // replace any temp nextNodeIds in its choices with the real ones.
    for (final MapEntry<String, String> entry in tempToReal.entries) {
      final String realId = entry.value;

      // Find the original node to get its choices
      final QuestNode originalNode = workingNodes.firstWhere((QuestNode n) => n.id == entry.key);

      // Check if any choices reference temp IDs that need resolving
      bool needsUpdate = false;
      final List<QuestChoice> resolvedChoices = originalNode.choices.map((QuestChoice c) {
        final String resolvedNextId = tempToReal[c.nextNodeId] ?? c.nextNodeId;
        if (resolvedNextId != c.nextNodeId) needsUpdate = true;
        return c.copyWith(nextNodeId: resolvedNextId);
      }).toList();

      // Only update if there were temp IDs to resolve (avoid unnecessary API calls)
      if (needsUpdate) {
        final QuestNode nodeToUpdate = originalNode.copyWith(id: realId, choices: resolvedChoices);
        await _nodeDataSource.updateItem(nodeToUpdate);
      }
    }

    return tempToReal;
  }

  /// Diffs current nodes against original, executing creates, updates, and
  /// deletes in the correct order.
  ///
  /// - Deletes: deepest-first to avoid dangling nextNodeId references mid-save
  /// - Creates: breadth-first with temp ID resolution
  /// - Updates: any order (IDs are already real)
  ///
  /// Returns temp ID → real ID map for newly created nodes.
  Future<Map<String, String>> _saveNodesDiff(
    List<QuestNode> current,
    List<QuestNode> original,
    String startNodeId,
  ) async {
    final Set<String> originalIds = original.map((QuestNode n) => n.id).toSet();
    final Set<String> currentIds = current.map((QuestNode n) => n.id).toSet();

    // ── Identify operations ──

    // New nodes: temp/empty IDs (not in original set, starts with 'temp_' or is empty)
    final List<QuestNode> toCreate = current.where((QuestNode n) => n.id.isEmpty || n.id.startsWith('temp_')).toList();

    // Updated nodes: real IDs present in both lists
    final List<QuestNode> toUpdate = current
        .where((QuestNode n) => n.id.isNotEmpty && !n.id.startsWith('temp_') && originalIds.contains(n.id))
        .toList();

    // Deleted nodes: in original but absent from current (compared by id)
    final List<QuestNode> toDelete = original.where((QuestNode n) => !currentIds.contains(n.id)).toList();

    // ── Execute deletes (deepest-first) ──
    // Sort by depth from start node - deepest nodes first so parent references
    // aren't broken while children still exist
    final Map<String, int> depthMap = _buildDepthMap(original, startNodeId);
    toDelete.sort((QuestNode a, QuestNode b) => (depthMap[b.id] ?? 0).compareTo(depthMap[a.id] ?? 0));

    for (final QuestNode node in toDelete) {
      await _nodeDataSource.deleteItem(node);
    }

    // ── Execute creates (breadth-first with temp ID resolution) ──
    final Map<String, String> tempToReal = await _saveNodesBreadthFirst(toCreate, startNodeId);

    // ── Resolve any remaining temp IDs in updated nodes' choices ──
    final List<QuestNode> resolvedUpdates = toUpdate.map((QuestNode node) {
      List<QuestChoice> resolvedChoices = node.choices.map((QuestChoice c) {
        final String realId = tempToReal[c.nextNodeId] ?? c.nextNodeId;
        return c.copyWith(nextNodeId: realId);
      }).toList();
      return node.copyWith(choices: resolvedChoices);
    }).toList();

    // ── Execute updates ──
    for (final QuestNode node in resolvedUpdates) {
      await _nodeDataSource.updateItem(node);
    }

    return tempToReal;
  }

  /// Builds a map of node ID → depth from the start node using BFS.
  /// Used to sort deletions deepest-first.
  Map<String, int> _buildDepthMap(List<QuestNode> nodes, String startNodeId) {
    final Map<String, QuestNode> nodeMap = <String, QuestNode>{for (final QuestNode n in nodes) n.id: n};
    final Map<String, int> depths = <String, int>{};
    final Queue<String> queue = Queue<String>();
    queue.add(startNodeId);
    depths[startNodeId] = 0;

    while (queue.isNotEmpty) {
      final String currentId = queue.removeFirst();
      final QuestNode? node = nodeMap[currentId];
      if (node == null) continue;

      for (final QuestChoice choice in node.choices) {
        if (choice.nextNodeId.isNotEmpty && !depths.containsKey(choice.nextNodeId)) {
          depths[choice.nextNodeId] = (depths[currentId] ?? 0) + 1;
          queue.add(choice.nextNodeId);
        }
      }
    }

    return depths;
  }
}
