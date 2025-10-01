import 'package:drift/drift.dart';

class FolderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer()();

  // 'dm' or 'channel' for now
  TextColumn get itemType => text()();
  IntColumn get targetId => integer()();

  // optional topic name for future
  TextColumn get topicName => text().nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(folder_id, item_type, target_id, topic_name)'
      ];
}

