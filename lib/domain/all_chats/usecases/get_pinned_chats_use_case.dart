import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPinnedChatsUseCase {
  final PinnedChatsRepository _repository;
  GetPinnedChatsUseCase(this._repository);

  Future<List<PinnedChatEntity>> call(int folderId) async {
    return await _repository.getPinnedChats(folderId);
  }
}
