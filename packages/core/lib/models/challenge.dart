import 'package:core/enums/enums.dart';
import 'package:core/models/content_base.dart';

class Challenge extends ContentBase {
  ChallengeType type;
  String title;
  String description;
  int xpReward;
  Difficulty difficulty;
  DisasterType disasterType;
  String? questId;
  String? unlocksSectionType;

  Challenge({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required super.source,
    super.isPublished,
    required this.type,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.difficulty,
    required this.disasterType,
    this.questId,
    this.unlocksSectionType,
  });

  @override
  Challenge copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    ContentSource? source,
    bool? isPublished,
    ChallengeType? type,
    String? title,
    String? description,
    int? xpReward,
    Difficulty? difficulty,
    DisasterType? disasterType,
    String? questId,
    String? unlocksSectionType,
  }) {
    return Challenge(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      source: source ?? this.source,
      isPublished: isPublished ?? this.isPublished,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
      disasterType: disasterType ?? this.disasterType,
      questId: questId ?? this.questId,
      unlocksSectionType: unlocksSectionType ?? this.unlocksSectionType,
    );
  }
}
