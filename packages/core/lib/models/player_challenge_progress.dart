import 'package:core/models/model_base.dart';

class PlayerChallengeProgress extends ModelBase {
  String userId;
  String challengeId;
  bool isCompleted;
  int currentQuestionIndex;
  List<int> answers;
  int correctCount;
  int xpEarned;
  DateTime? completedAt;

  PlayerChallengeProgress({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.userId,
    required this.challengeId,
    this.isCompleted = false,
    this.currentQuestionIndex = 0,
    this.answers = const [],
    this.correctCount = 0,
    this.xpEarned = 0,
    this.completedAt,
  });

  @override
  PlayerChallengeProgress copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? userId,
    String? challengeId,
    bool? isCompleted,
    int? currentQuestionIndex,
    List<int>? answers,
    int? correctCount,
    int? xpEarned,
    DateTime? completedAt,
  }) {
    return PlayerChallengeProgress(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      isCompleted: isCompleted ?? this.isCompleted,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      correctCount: correctCount ?? this.correctCount,
      xpEarned: xpEarned ?? this.xpEarned,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
