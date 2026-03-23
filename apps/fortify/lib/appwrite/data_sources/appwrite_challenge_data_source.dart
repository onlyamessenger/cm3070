import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/challenge_mapper.dart';

class AppWriteChallengeDataSource extends AppWriteDataSource<Challenge> {
  AppWriteChallengeDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: ChallengeMapper());
}
