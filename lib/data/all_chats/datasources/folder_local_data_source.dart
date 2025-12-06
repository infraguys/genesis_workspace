import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderLocalDataSource {
  final FolderDao _dao;
  FolderLocalDataSource(this._dao);

  Future<void> add(FolderEntity entity, {required int organizationId}) async {
    await _dao.insertFolder(
      title: entity.title,
      backgroundColorValue: entity.backgroundColor.toARGB32(),
      unreadMessages: entity.unreadMessages.toSet(),
      organizationId: organizationId,
      uuid: entity.uuid,
      systemType: entity.systemType.name,
    );
  }

  Future<void> replaceAll(List<FolderEntity> folders, {required int organizationId}) async {
    await _dao.deleteByOrganization(organizationId);
    for (final f in folders) {
      await add(f, organizationId: organizationId);
    }
  }

  Future<List<Folder>> getAll(int organizationId) async {
    final List<Folder> rows = await _dao.getAll(organizationId);
    return rows;
  }

  Future<void> update(FolderItemEntity folder) async {
    if (folder.title == null) return;
    await _dao.updateFolder(
      uuid: folder.id?.toString() ?? '',
      title: folder.title,
      backgroundColorValue: folder.backgroundColor?.value,
      unreadMessages: folder.unreadMessages,
    );
  }

  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }
}
