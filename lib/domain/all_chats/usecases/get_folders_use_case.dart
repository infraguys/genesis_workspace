import 'package:flutter/material.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFoldersUseCase {
  final FolderRepository _repository;
  final PinnedChatsRepository _pinnedChatsRepository;
  GetFoldersUseCase(this._repository, this._pinnedChatsRepository);

  Future<List<FolderItemEntity>> call() async {
    final List<Folder> rows = await _repository.getFolders();
    final List<FolderItemEntity> result = [];
    for (var row in rows) {
      final folderPinnedChats = await _pinnedChatsRepository.getPinnedChats(row.id);
      final folder = FolderItemEntity(
        id: row.id,
        title: row.title,
        iconData: IconData(row.iconCodePoint, fontFamily: 'MaterialIcons'),
        unreadCount: row.unreadCount,
        backgroundColor: row.backgroundColorValue != null ? Color(row.backgroundColorValue!) : null,
        pinnedChats: folderPinnedChats,
      );
      result.add(folder);
    }
    return result;
  }
}
