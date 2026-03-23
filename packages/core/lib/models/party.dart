import 'package:core/models/model_base.dart';

class Party extends ModelBase {
  String name;
  String createdByUserId;
  int weeklyXpTarget;
  int weeklyXpCurrent;

  Party({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.name,
    required this.createdByUserId,
    this.weeklyXpTarget = 0,
    this.weeklyXpCurrent = 0,
  });

  @override
  Party copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? name,
    String? createdByUserId,
    int? weeklyXpTarget,
    int? weeklyXpCurrent,
  }) {
    return Party(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      weeklyXpTarget: weeklyXpTarget ?? this.weeklyXpTarget,
      weeklyXpCurrent: weeklyXpCurrent ?? this.weeklyXpCurrent,
    );
  }
}
