import 'package:appwrite/appwrite.dart';
import 'package:fortify/interface/services/services.dart';

class AppWriteService implements AppService {
  final Functions functions;

  AppWriteService({required this.functions});
}
