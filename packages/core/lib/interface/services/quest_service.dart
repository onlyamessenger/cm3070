import 'package:core/models/models.dart';

abstract class QuestService {
  Future<Quest> getQuest(String questId);
}
