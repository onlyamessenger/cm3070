import 'package:core/models/models.dart';

abstract class Mapper<T extends ModelBase> {
  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T item);
}
