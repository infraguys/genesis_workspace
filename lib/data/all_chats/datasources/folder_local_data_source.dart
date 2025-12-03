import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderLocalDataSource {
  final FolderDao _dao;
  FolderLocalDataSource(this._dao);

  Future<void> add(FolderEntity entity) async {
    await _dao.insertFolder(
      id: entity.id,
      title: entity.title,
      backgroundColorValue: entity.backgroundColor.toARGB32(),
      unreadMessages: entity.unreadMessages.toSet(),
      organizationId: -1,
      remoteUUID: entity.uuid,
    );
  }

  Future<List<Folder>> getAll(int organizationId) async {
    final List<Folder> rows = await _dao.getAll(organizationId);
    return rows;
  }

  Future<void> update(FolderItemEntity folder) async {
    if (folder.id == null) return;
    await _dao.updateFolder(
      id: folder.id!,
      title: folder.title,
      backgroundColorValue: folder.backgroundColor?.value,
      unreadMessages: folder.unreadMessages,
    );
  }

  Future<void> delete(int id) async {
    await _dao.deleteById(id);
  }
}
