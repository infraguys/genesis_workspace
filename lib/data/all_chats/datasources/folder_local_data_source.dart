import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderLocalDataSource {
  final FolderDao _dao;
  FolderLocalDataSource(this._dao);

  Future<void> add(FolderItemEntity entity) async {
    await _dao.insertFolder(
      id: entity.id,
      title: entity.title ?? '',
      iconCodePoint: entity.iconData.codePoint,
      backgroundColorValue: entity.backgroundColor?.value,
      unreadMessages: entity.unreadMessages,
      organizationId: entity.organizationId,
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
      iconCodePoint: folder.iconData.codePoint,
      backgroundColorValue: folder.backgroundColor?.value,
      unreadMessages: folder.unreadMessages,
    );
  }

  Future<void> delete(int id) async {
    await _dao.deleteById(id);
  }
}
