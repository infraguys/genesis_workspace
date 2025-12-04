import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFolderIdsForChatUseCase {
  final FolderMembershipRepository _repository;
  GetFolderIdsForChatUseCase(this._repository);

  Future<List<String>> call(int chatId) async {
    return _repository.getFolderIdsForChat(chatId);
  }
}
