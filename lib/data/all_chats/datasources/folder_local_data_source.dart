import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
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
      title: entity.title ?? '',
      iconCodePoint: entity.iconData.codePoint,
      backgroundColorValue: entity.backgroundColor?.value,
      unreadCount: entity.unreadCount,
    );
  }

  Future<List<FolderItemEntity>> getAll() async {
    final List<Folder> rows = await _dao.getAll();
    return rows.map(_mapDbToEntity).toList(growable: false);
  }

  FolderItemEntity _mapDbToEntity(Folder row) {
    return FolderItemEntity(
      id: row.id,
      title: row.title,
      iconData: FolderIconsConstants.resolve(row.iconCodePoint),
      backgroundColor: row.backgroundColorValue != null ? Color(row.backgroundColorValue!) : null,
      unreadCount: row.unreadCount,
    );
  }

  Future<void> update(FolderItemEntity folder) async {
    if (folder.id == null) return;
    await _dao.updateFolder(
      id: folder.id!,
      title: folder.title,
      iconCodePoint: folder.iconData.codePoint,
      backgroundColorValue: folder.backgroundColor?.value,
      unreadCount: folder.unreadCount,
    );
  }

  Future<void> delete(int id) async {
    await _dao.deleteById(id);
  }
}
