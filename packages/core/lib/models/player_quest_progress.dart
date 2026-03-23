import 'package:core/models/model_base.dart';

class PlayerQuestProgress extends ModelBase {
  String userId;
  String questId;
  String currentNodeId;
  bool isCompleted;
  List<String> visitedNodeIds;
  int xpEarned;
  DateTime? completedAt;

  PlayerQuestProgress({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.userId,
    required this.questId,
    required this.currentNodeId,
    this.isCompleted = false,
    this.visitedNodeIds = const [],
    this.xpEarned = 0,
    this.completedAt,
  });

  @override
  PlayerQuestProgress copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? userId,
    String? questId,
    String? currentNodeId,
    bool? isCompleted,
    List<String>? visitedNodeIds,
    int? xpEarned,
    DateTime? completedAt,
  }) {
    return PlayerQuestProgress(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      questId: questId ?? this.questId,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      isCompleted: isCompleted ?? this.isCompleted,
      visitedNodeIds: visitedNodeIds ?? this.visitedNodeIds,
      xpEarned: xpEarned ?? this.xpEarned,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
