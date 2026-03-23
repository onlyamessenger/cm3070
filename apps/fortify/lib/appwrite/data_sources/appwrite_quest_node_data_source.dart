import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/quest_node_mapper.dart';

class AppWriteQuestNodeDataSource extends AppWriteDataSource<QuestNode> {
  AppWriteQuestNodeDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: QuestNodeMapper());
}
