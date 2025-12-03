import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SetFoldersForChatUseCase {
  final FolderMembershipRepository _repository;
  SetFoldersForChatUseCase(this._repository);

  Future<void> call(
    int chatId,
    List<String> folderUuids,
  ) async {
    await _repository.setFoldersForChat(
      chatId,
      folderUuids,
    );
  }
}
