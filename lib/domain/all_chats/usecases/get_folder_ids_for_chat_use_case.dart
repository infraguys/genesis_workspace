import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFolderIdsForChatUseCase {
  final FolderMembershipRepository _repository;
  GetFolderIdsForChatUseCase(this._repository);

  Future<List<int>> call(
    int chatId, {
    required int organizationId,
  }) async {
    return _repository.getFolderIdsForChat(
      chatId,
      organizationId: organizationId,
    );
  }
}
