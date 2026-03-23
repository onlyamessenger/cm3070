import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/bonus_event_mapper.dart';

class AppWriteBonusEventDataSource extends AppWriteDataSource<BonusEvent> {
  AppWriteBonusEventDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: BonusEventMapper());
}
