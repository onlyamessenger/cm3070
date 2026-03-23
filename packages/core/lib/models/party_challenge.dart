import 'package:core/enums/enums.dart';
import 'package:core/models/content_base.dart';

class PartyChallenge extends ContentBase {
  String partyId;
  PartyChallengeType type;
  String title;
  String description;
  bool isCompleted;
  bool isWeatherTriggered;
  DateTime? expiresAt;
  String taskData;
  String memberProgress;

  PartyChallenge({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required super.source,
    super.isPublished,
    required this.partyId,
    required this.type,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isWeatherTriggered = false,
    this.expiresAt,
    this.taskData = '{}',
    this.memberProgress = '{}',
  });

  @override
  PartyChallenge copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    ContentSource? source,
    bool? isPublished,
    String? partyId,
    PartyChallengeType? type,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isWeatherTriggered,
    DateTime? expiresAt,
    String? taskData,
    String? memberProgress,
  }) {
    return PartyChallenge(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      source: source ?? this.source,
      isPublished: isPublished ?? this.isPublished,
      partyId: partyId ?? this.partyId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isWeatherTriggered: isWeatherTriggered ?? this.isWeatherTriggered,
      expiresAt: expiresAt ?? this.expiresAt,
      taskData: taskData ?? this.taskData,
      memberProgress: memberProgress ?? this.memberProgress,
    );
  }
}
