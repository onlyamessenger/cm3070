import 'package:core/models/model_base.dart';

class ChallengeQuestion extends ModelBase {
  String challengeId;
  int sortOrder;
  String questionText;
  List<String> options;
  int correctIndex;

  ChallengeQuestion({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.challengeId,
    required this.sortOrder,
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  @override
  ChallengeQuestion copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? challengeId,
    int? sortOrder,
    String? questionText,
    List<String>? options,
    int? correctIndex,
  }) {
    return ChallengeQuestion(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      challengeId: challengeId ?? this.challengeId,
      sortOrder: sortOrder ?? this.sortOrder,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}
