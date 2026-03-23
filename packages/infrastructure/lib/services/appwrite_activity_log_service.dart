import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteActivityLogService implements ActivityLogService {
  final Databases _databases;
  final String _databaseId;

  AppWriteActivityLogService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<void> logActivity({
    required String userId,
    required String action,
    required int xp,
    required double multiplier,
    required ActivitySourceType sourceType,
  }) async {
    await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: 'activity_log',
      documentId: ID.unique(),
      data: <String, dynamic>{
        'userId': userId,
        'action': action,
        'xpAmount': xp,
        'sourceType': sourceType.name,
        'multiplierApplied': multiplier,
        'createdBy': userId,
        'updatedBy': userId,
        'isDeleted': false,
      },
    );
  }
}
