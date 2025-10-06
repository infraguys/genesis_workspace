import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdatePinnedChatOrderUseCase {
  final PinnedChatsRepository _repository;
  UpdatePinnedChatOrderUseCase(this._repository);
  Future<void> call({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
  }) async {
    return await _repository.updatePinnedChatOrder(
      folderId: folderId,
      movedChatId: movedChatId,
      previousChatId: previousChatId,
      nextChatId: nextChatId,
    );
  }
}
