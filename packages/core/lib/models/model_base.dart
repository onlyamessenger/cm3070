/// Base class for all domain models.
///
/// Fields [id], [created], and [updated] map to AppWrite's built-in
/// `$id`, `$createdAt`, and `$updatedAt` document fields.
/// Fields [createdBy], [updatedBy], and [isDeleted] are stored as
/// custom attributes on every collection.
class ModelBase {
  String id;
  DateTime created;
  DateTime updated;
  String createdBy;
  String updatedBy;
  bool isDeleted;

  ModelBase({
    required this.id,
    required this.created,
    required this.updated,
    required this.createdBy,
    required this.updatedBy,
    this.isDeleted = false,
  });

  ModelBase copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
  }) {
    return ModelBase(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
