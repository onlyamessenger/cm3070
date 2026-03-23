import 'package:core/enums/enums.dart';
import 'package:core/models/content_base.dart';

class Quest extends ContentBase {
  String title;
  String description;
  int totalDays;
  String startNodeId;
  Difficulty difficulty;
  DisasterType disasterType;
  String? region;

  Quest({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required super.source,
    super.isPublished,
    required this.title,
    required this.description,
    required this.totalDays,
    required this.startNodeId,
    required this.difficulty,
    required this.disasterType,
    this.region,
  });

  @override
  Quest copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    ContentSource? source,
    bool? isPublished,
    String? title,
    String? description,
    int? totalDays,
    String? startNodeId,
    Difficulty? difficulty,
    DisasterType? disasterType,
    String? region,
  }) {
    return Quest(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      source: source ?? this.source,
      isPublished: isPublished ?? this.isPublished,
      title: title ?? this.title,
      description: description ?? this.description,
      totalDays: totalDays ?? this.totalDays,
      startNodeId: startNodeId ?? this.startNodeId,
      difficulty: difficulty ?? this.difficulty,
      disasterType: disasterType ?? this.disasterType,
      region: region ?? this.region,
    );
  }
}
