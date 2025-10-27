import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';

class PinnedChatEntity {
  final int id;
  final int folderId;
  final int chatId;
  final int? orderIndex;
  final DateTime pinnedAt;
  final PinnedChatType type;
  final int organizationId;

  PinnedChatEntity({
    required this.id,
    required this.folderId,
    required this.chatId,
    required this.pinnedAt,
    this.orderIndex,
    required this.type,
    required this.organizationId,
  });
}
