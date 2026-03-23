import 'package:core/core.dart';

import 'package:fortify/appwrite/appwrite_data_source.dart';
import 'package:fortify/appwrite/mappers/kit_item_mapper.dart';

class AppWriteKitItemDataSource extends AppWriteDataSource<KitItem> {
  AppWriteKitItemDataSource({required super.databases, required super.databaseId, required super.collectionId})
    : super(mapper: KitItemMapper());
}
