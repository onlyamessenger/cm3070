import 'package:core/enums/enums.dart';

abstract class ActivityLogService {
  Future<void> logActivity({
    required String userId,
    required String action,
    required int xp,
    required double multiplier,
    required ActivitySourceType sourceType,
  });
}
