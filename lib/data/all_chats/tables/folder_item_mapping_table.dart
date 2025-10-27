import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

class FolderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId =>
      integer().references(Folders, #id, onDelete: KeyAction.cascade)();
  IntColumn get organizationId =>
      integer().references(Organizations, #id, onDelete: KeyAction.cascade)();

  // 'dm' or 'channel' for now
  TextColumn get itemType => text()();
  IntColumn get targetId => integer()();

  // optional topic name for future
  TextColumn get topicName => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(folder_id, item_type, target_id, topic_name)'];
}
