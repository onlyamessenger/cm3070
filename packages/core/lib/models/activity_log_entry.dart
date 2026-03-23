import 'package:core/enums/enums.dart';
import 'package:core/models/model_base.dart';

class ActivityLogEntry extends ModelBase {
  String userId;
  String action;
  int xpAmount;
  ActivitySourceType? sourceType;
  String? sourceId;
  double? multiplierApplied;

  ActivityLogEntry({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.userId,
    required this.action,
    required this.xpAmount,
    this.sourceType,
    this.sourceId,
    this.multiplierApplied,
  });

  @override
  ActivityLogEntry copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? userId,
    String? action,
    int? xpAmount,
    ActivitySourceType? sourceType,
    String? sourceId,
    double? multiplierApplied,
  }) {
    return ActivityLogEntry(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      xpAmount: xpAmount ?? this.xpAmount,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      multiplierApplied: multiplierApplied ?? this.multiplierApplied,
    );
  }
}
