import 'package:core/core.dart';

class AppWriteLoggerService implements LoggerService {
  final dynamic _context;

  AppWriteLoggerService({required dynamic context}) : _context = context;

  @override
  void info(String message) {
    _context.log(message);
  }

  @override
  void error(String message) {
    _context.error(message);
  }
}
