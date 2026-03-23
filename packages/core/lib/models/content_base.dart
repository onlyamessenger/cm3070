import 'package:core/enums/enums.dart';
import 'package:core/models/model_base.dart';

class ContentBase extends ModelBase {
  ContentSource source;
  bool isPublished;

  ContentBase({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.source,
    this.isPublished = false,
  });

  @override
  ContentBase copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    ContentSource? source,
    bool? isPublished,
  }) {
    return ContentBase(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      source: source ?? this.source,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
