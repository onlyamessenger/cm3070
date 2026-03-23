import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/player_quest_progress_mapper.dart';

class AppWritePlayerQuestProgressDataSource extends AppWriteDataSource<PlayerQuestProgress> {
  AppWritePlayerQuestProgressDataSource({
    required super.databases,
    required super.databaseId,
    required super.collectionId,
  }) : super(mapper: PlayerQuestProgressMapper());
}
