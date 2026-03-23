import 'package:core/enums/enums.dart';
import 'package:core/models/content_base.dart';

class Level extends ContentBase {
  int level;
  String title;
  String description;
  String icon;
  int xpThreshold;

  Level({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required super.source,
    super.isPublished,
    required this.level,
    required this.title,
    this.description = '',
    required this.icon,
    required this.xpThreshold,
  });

  @override
  Level copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    ContentSource? source,
    bool? isPublished,
    int? level,
    String? title,
    String? description,
    String? icon,
    int? xpThreshold,
  }) {
    return Level(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      source: source ?? this.source,
      isPublished: isPublished ?? this.isPublished,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpThreshold: xpThreshold ?? this.xpThreshold,
    );
  }
}
