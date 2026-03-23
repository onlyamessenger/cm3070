import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/quest_mapper.dart';

class AppWriteQuestDataSource extends AppWriteDataSource<Quest> {
  AppWriteQuestDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: QuestMapper());
}
