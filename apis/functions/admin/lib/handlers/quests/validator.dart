/// Validates the quest's node graph structure.
///
/// Returns true if the quest graph is valid, false otherwise.
/// [onError] is called with a descriptive message when validation fails.
/// [onLog] is called with a success message when validation passes.
bool validateQuestGraph(
  Map<String, dynamic> quest, {
  void Function(String)? onError,
  void Function(String)? onLog,
}) {
  final List<dynamic> nodes = quest['nodes'] as List<dynamic>? ?? <dynamic>[];
  final String startNodeId = quest['startNodeId'] as String? ?? '';

  if (nodes.isEmpty || startNodeId.isEmpty) {
    onError?.call('Quest "${quest['title']}": empty nodes or missing startNodeId');
    return false;
  }

  // Build node ID set
  final Set<String> nodeIds = <String>{};
  for (final dynamic n in nodes) {
    nodeIds.add((n as Map<String, dynamic>)['id'] as String);
  }

  // Check startNodeId exists
  if (!nodeIds.contains(startNodeId)) {
    onError?.call('Quest "${quest['title']}": startNodeId "$startNodeId" not in nodes');
    return false;
  }

  // Check all choice nextNodeIds reference existing nodes
  for (final dynamic n in nodes) {
    final Map<String, dynamic> node = n as Map<String, dynamic>;
    final List<dynamic> choices = node['choices'] as List<dynamic>? ?? <dynamic>[];
    final bool isOutcome = node['isOutcome'] as bool? ?? false;

    // Leaf nodes must be outcomes
    if (choices.isEmpty && !isOutcome) {
      onError?.call('Quest "${quest['title']}": node "${node['id']}" has no choices but is not an outcome');
      return false;
    }

    for (final dynamic c in choices) {
      final String nextId = (c as Map<String, dynamic>)['nextNodeId'] as String;
      if (!nodeIds.contains(nextId)) {
        onError?.call('Quest "${quest['title']}": choice references non-existent node "$nextId"');
        return false;
      }
    }
  }

  // Cycle detection via DFS from startNodeId
  final Map<String, List<String>> adjacency = <String, List<String>>{};
  for (final dynamic n in nodes) {
    final Map<String, dynamic> node = n as Map<String, dynamic>;
    final String id = node['id'] as String;
    final List<dynamic> choices = node['choices'] as List<dynamic>? ?? <dynamic>[];
    adjacency[id] = choices.map((dynamic c) => (c as Map<String, dynamic>)['nextNodeId'] as String).toList();
  }

  final Set<String> visited = <String>{};
  final Set<String> inStack = <String>{};

  bool hasCycle(String nodeId) {
    if (inStack.contains(nodeId)) return true;
    if (visited.contains(nodeId)) return false;
    visited.add(nodeId);
    inStack.add(nodeId);
    for (final String next in adjacency[nodeId] ?? <String>[]) {
      if (hasCycle(next)) return true;
    }
    inStack.remove(nodeId);
    return false;
  }

  if (hasCycle(startNodeId)) {
    onError?.call('Quest "${quest['title']}": cycle detected in node graph');
    return false;
  }

  // Check all nodes are reachable from startNodeId
  if (visited.length < nodeIds.length) {
    final Set<String> unreachable = nodeIds.difference(visited);
    onError?.call('Quest "${quest['title']}": ${unreachable.length} unreachable nodes: $unreachable');
    return false;
  }

  onLog?.call('Quest "${quest['title']}" passed validation (${nodeIds.length} nodes, no cycles, all reachable)');
  return true;
}
