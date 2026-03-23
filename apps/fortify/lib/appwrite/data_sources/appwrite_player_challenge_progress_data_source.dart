import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/player_challenge_progress_mapper.dart';

class AppWritePlayerChallengeProgressDataSource extends AppWriteDataSource<PlayerChallengeProgress> {
  AppWritePlayerChallengeProgressDataSource({
    required super.databases,
    required super.databaseId,
    required super.collectionId,
  }) : super(mapper: PlayerChallengeProgressMapper());
}
