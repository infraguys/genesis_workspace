import 'dart:convert';

import 'package:drift/drift.dart';

class UnreadMessagesConverter extends TypeConverter<Set<int>, String> {
  const UnreadMessagesConverter();

  @override
  Set<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return <int>{};
    }
    final dynamic decoded = jsonDecode(fromDb);
    if (decoded is List) {
      return decoded.whereType<num>().map((num value) => value.toInt()).toSet();
    }
    return <int>{};
  }

  @override
  String toSql(Set<int> value) => jsonEncode(value.toList());
}

class Organizations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get baseUrl => text()();
  TextColumn get unreadMessages => text().map(const UnreadMessagesConverter()).withDefault(const Constant('[]'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {baseUrl},
    {id},
  ];
}
