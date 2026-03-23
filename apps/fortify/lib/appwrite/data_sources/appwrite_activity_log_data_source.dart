import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/activity_log_entry_mapper.dart';

class AppWriteActivityLogDataSource extends AppWriteDataSource<ActivityLogEntry> {
  AppWriteActivityLogDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: ActivityLogEntryMapper());
}
