import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

class FolderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().references(Folders, #id, onDelete: KeyAction.cascade)();
  IntColumn get organizationId =>
      integer().references(Organizations, #id, onDelete: KeyAction.cascade)();
  IntColumn get chatId => integer()();

  @override
  List<String> get customConstraints => ['UNIQUE(folder_id, chat_id)'];
}
