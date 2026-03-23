import 'package:core/models/model_base.dart';

class BonusEvent extends ModelBase {
  String title;
  String description;
  double multiplier;
  DateTime startsAt;
  DateTime endsAt;
  bool isActive;

  BonusEvent({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.title,
    required this.description,
    required this.multiplier,
    required this.startsAt,
    required this.endsAt,
    this.isActive = false,
  });

  @override
  BonusEvent copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? title,
    String? description,
    double? multiplier,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isActive,
  }) {
    return BonusEvent(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      title: title ?? this.title,
      description: description ?? this.description,
      multiplier: multiplier ?? this.multiplier,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
