import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class PinChatUseCase {
  final PinnedChatsRepository _repository;
  PinChatUseCase(this._repository);

  Future<void> call({required int folderId, required int chatId}) async {
    return await _repository.pinChat(folderId: folderId, chatId: chatId);
  }
}
