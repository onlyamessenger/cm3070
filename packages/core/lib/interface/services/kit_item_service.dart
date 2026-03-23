import 'package:core/models/models.dart';

abstract class KitItemService {
  Future<List<KitItem>> getPublishedTemplates();
  Future<KitItem> createKitItem(KitItem item);
}
