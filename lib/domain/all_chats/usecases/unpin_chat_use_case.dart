import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UnpinChatUseCase {
  final PinnedChatsRepository _repository;
  UnpinChatUseCase(this._repository);

  Future<void> call({
    required String folderUuid,
    required int chatId,
  }) async {
    return await _repository.unpinChat(folderUuid: folderUuid, chatId: chatId);
  }
}
