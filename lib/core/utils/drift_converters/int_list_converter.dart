import 'dart:convert';

import 'package:drift/drift.dart';

class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return (jsonDecode(fromDb) as List<dynamic>).cast<int>();
  }

  @override
  String toSql(List<int> value) {
    return jsonEncode(value);
  }
}
