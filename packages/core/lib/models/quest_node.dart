import 'package:core/models/model_base.dart';
import 'package:core/models/quest_choice.dart';

class QuestNode extends ModelBase {
  String questId;
  int day;
  String text;
  bool isOutcome;
  int xpReward;
  String? summary;
  List<QuestChoice> choices;
  String? unlocksSectionType;

  QuestNode({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.questId,
    required this.day,
    required this.text,
    this.isOutcome = false,
    this.xpReward = 0,
    this.summary,
    this.choices = const [],
    this.unlocksSectionType,
  });

  @override
  QuestNode copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? questId,
    int? day,
    String? text,
    bool? isOutcome,
    int? xpReward,
    String? summary,
    List<QuestChoice>? choices,
    String? unlocksSectionType,
    bool clearSummary = false,
    bool clearUnlocksSectionType = false,
  }) {
    return QuestNode(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      questId: questId ?? this.questId,
      day: day ?? this.day,
      text: text ?? this.text,
      isOutcome: isOutcome ?? this.isOutcome,
      xpReward: xpReward ?? this.xpReward,
      summary: clearSummary ? null : (summary ?? this.summary),
      choices: choices ?? this.choices,
      unlocksSectionType: clearUnlocksSectionType ? null : (unlocksSectionType ?? this.unlocksSectionType),
    );
  }
}
