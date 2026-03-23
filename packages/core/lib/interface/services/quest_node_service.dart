import 'package:core/models/models.dart';

abstract class QuestNodeService {
  Future<QuestNode> getNode(String nodeId);
  Future<List<QuestNode>> getNodesForQuest(String questId);
}
