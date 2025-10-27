import 'package:drift/drift.dart';

class Organizations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get baseUrl => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {baseUrl},
    {id},
  ];
}
