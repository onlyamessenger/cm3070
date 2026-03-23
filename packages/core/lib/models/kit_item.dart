import 'package:core/enums/enums.dart';
import 'package:core/models/content_base.dart';

class KitItem extends ContentBase {
  String? userId;
  String itemName;
  String description;
  int sortOrder;
  bool isChecked;
  DateTime? checkedAt;

  KitItem({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required super.source,
    super.isPublished,
    this.userId,
    required this.itemName,
    this.description = '',
    required this.sortOrder,
    this.isChecked = false,
    this.checkedAt,
  });

  @override
  KitItem copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    ContentSource? source,
    bool? isPublished,
    String? userId,
    String? itemName,
    String? description,
    int? sortOrder,
    bool? isChecked,
    DateTime? checkedAt,
  }) {
    return KitItem(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      source: source ?? this.source,
      isPublished: isPublished ?? this.isPublished,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}
