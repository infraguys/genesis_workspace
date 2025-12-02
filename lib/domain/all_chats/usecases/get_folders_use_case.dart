import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFoldersUseCase {
  final FolderRepository _repository;
  final PinnedChatsRepository _pinnedChatsRepository;

  GetFoldersUseCase(this._repository, this._pinnedChatsRepository);

  Future<List<FolderEntity>> call(int organizationId) async {
    final List<Folder> rows = await _repository.getFolders(organizationId);
    final List<FolderEntity> result = [];
    for (var row in rows) {
      final folderPinnedChats = await _pinnedChatsRepository.getPinnedChats(
        folderId: row.id,
        organizationId: organizationId,
      );
      final folder = FolderEntity(
        id: row.id,
        title: row.title,
        unreadMessages: row.unreadMessages.toList(),
        backgroundColorValue: row.backgroundColorValue ?? AppConstants.folderColors.first.toARGB32(),
        organizationId: row.organizationId,
        uuid: row.remoteUUID,
        createdAt: '',
        updatedAt: '',
        systemType: FolderSystemType.created,
      );
      result.add(folder);
    }
    return result;
  }
}
