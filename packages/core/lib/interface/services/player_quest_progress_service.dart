import 'package:core/models/models.dart';

abstract class PlayerQuestProgressService {
  Future<PlayerQuestProgress> getProgress(String progressId);
  Future<void> markCompleted({required String progressId, required int xpEarned, required DateTime completedAt});
}
