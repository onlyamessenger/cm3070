import 'package:core/enums/enums.dart';
import 'package:core/models/model_base.dart';

class ReadinessSection extends ModelBase {
  String userId;
  ReadinessSectionType sectionType;
  bool isUnlocked;
  DateTime? unlockedAt;
  String? unlockedByType;
  String? unlockedById;

  ReadinessSection({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.userId,
    required this.sectionType,
    this.isUnlocked = false,
    this.unlockedAt,
    this.unlockedByType,
    this.unlockedById,
  });

  @override
  ReadinessSection copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? userId,
    ReadinessSectionType? sectionType,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? unlockedByType,
    String? unlockedById,
  }) {
    return ReadinessSection(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      sectionType: sectionType ?? this.sectionType,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockedByType: unlockedByType ?? this.unlockedByType,
      unlockedById: unlockedById ?? this.unlockedById,
    );
  }
}
