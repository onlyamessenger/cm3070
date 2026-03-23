import 'package:core/core.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

class AppWriteBonusEventService implements BonusEventService {
  final Databases _databases;
  final String _databaseId;

  AppWriteBonusEventService({required Databases databases, required String databaseId})
    : _databases = databases,
      _databaseId = databaseId;

  @override
  Future<List<BonusEvent>> getActiveEvents(DateTime now) async {
    final String nowStr = now.toIso8601String();
    final result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'bonus_events',
      queries: <String>[
        Query.lessThanEqual('startsAt', nowStr),
        Query.greaterThanEqual('endsAt', nowStr),
        Query.equal('isActive', true),
      ],
    );

    return result.documents.map((doc) {
      return BonusEvent(
        id: doc.$id,
        created: DateTime.parse(doc.$createdAt),
        updated: DateTime.parse(doc.$updatedAt),
        createdBy: doc.data['createdBy'] as String,
        updatedBy: doc.data['updatedBy'] as String,
        title: doc.data['title'] as String,
        description: doc.data['description'] as String? ?? '',
        multiplier: (doc.data['multiplier'] as num).toDouble(),
        startsAt: DateTime.parse(doc.data['startsAt'] as String),
        endsAt: DateTime.parse(doc.data['endsAt'] as String),
        isActive: doc.data['isActive'] as bool? ?? false,
      );
    }).toList();
  }
}
