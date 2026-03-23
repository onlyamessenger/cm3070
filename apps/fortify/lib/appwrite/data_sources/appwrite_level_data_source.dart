import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/level_mapper.dart';

class AppWriteLevelDataSource extends AppWriteDataSource<Level> {
  AppWriteLevelDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: LevelMapper());
}
