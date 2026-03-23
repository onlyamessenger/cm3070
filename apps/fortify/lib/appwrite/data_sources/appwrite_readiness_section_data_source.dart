import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/readiness_section_mapper.dart';

class AppWriteReadinessSectionDataSource extends AppWriteDataSource<ReadinessSection> {
  AppWriteReadinessSectionDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: ReadinessSectionMapper());
}
