import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/challenge_question_mapper.dart';

class AppWriteChallengeQuestionDataSource extends AppWriteDataSource<ChallengeQuestion> {
  AppWriteChallengeQuestionDataSource({
    required super.databases,
    required super.databaseId,
    required super.collectionId,
  }) : super(mapper: ChallengeQuestionMapper());
}
