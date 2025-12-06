import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdatePinnedChatOrderUseCase {
  final PinnedChatsRepository _repository;
  UpdatePinnedChatOrderUseCase(this._repository);
  Future<void> call({
    required String folderUuid,
    required String folderItemUuid,
    int? orderIndex,
  }) async {
    return await _repository.updatePinnedChatOrder(
      folderUuid: folderUuid,
      folderItemUuid: folderItemUuid,
      orderIndex: orderIndex,
    );
  }
}
