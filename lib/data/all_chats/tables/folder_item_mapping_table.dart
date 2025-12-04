import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

class FolderItems extends Table {
  TextColumn get uuid => text()();
  TextColumn get folderUuid => text().references(Folders, #uuid, onDelete: KeyAction.cascade)();
  IntColumn get organizationId => integer().references(Organizations, #id, onDelete: KeyAction.cascade)();
  IntColumn get chatId => integer()();

  @override
  Set<Column> get primaryKey => {uuid};

  @override
  List<String> get customConstraints => ['UNIQUE(folder_uuid, chat_id)'];
}
