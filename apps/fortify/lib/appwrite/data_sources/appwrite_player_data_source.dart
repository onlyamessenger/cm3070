import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/player_mapper.dart';

class AppWritePlayerDataSource extends AppWriteDataSource<Player> {
  AppWritePlayerDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: PlayerMapper());
}
