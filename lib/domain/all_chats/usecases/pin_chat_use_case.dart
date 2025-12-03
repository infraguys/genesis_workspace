import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class PinChatUseCase {
  final PinnedChatsRepository _repository;
  PinChatUseCase(this._repository);

  Future<void> call({
    required String folderUuid,
    required int chatId,
    int? orderIndex,
  }) async {
    return await _repository.pinChat(
      folderUuid: folderUuid,
      chatId: chatId,
      orderIndex: orderIndex,
    );
  }
}
