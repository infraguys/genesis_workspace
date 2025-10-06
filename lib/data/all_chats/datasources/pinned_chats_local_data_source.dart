import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

@injectable
class PinnedChatsLocalDataSource {
  final PinnedChatsDao _dao;
  PinnedChatsLocalDataSource(this._dao);

  Future<void> pinChat({required int folderId, required int chatId}) async {
    return await _dao.pinChat(folderId: folderId, chatId: chatId);
  }

  Future<void> unpinChat(int id) async {
    return await _dao.unpinChat(id);
  }

  Future<List<PinnedChat>> getPinnedChats(int folderId) async {
    return await _dao.getPinnedChats(folderId);
  }
}
