import 'package:core/models/models.dart';

abstract class BonusEventService {
  Future<List<BonusEvent>> getActiveEvents(DateTime now);
}
