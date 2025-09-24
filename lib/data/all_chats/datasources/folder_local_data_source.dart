import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

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
      title: row.title,
      iconData: IconData(row.iconCodePoint, fontFamily: 'MaterialIcons'),
      backgroundColor: row.backgroundColorValue != null ? Color(row.backgroundColorValue!) : null,
      unreadCount: row.unreadCount,
    );
  }
}

