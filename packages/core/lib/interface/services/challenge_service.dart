import 'package:core/models/models.dart';

abstract class ChallengeService {
  Future<Challenge> getChallenge(String challengeId);
  Future<int> getQuestionCount(String challengeId);
}
