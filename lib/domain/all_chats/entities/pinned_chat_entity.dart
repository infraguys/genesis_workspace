class PinnedChatEntity {
  final int id;
  final int folderId;
  final int chatId;
  final DateTime pinnedAt;

  PinnedChatEntity({
    required this.id,
    required this.folderId,
    required this.chatId,
    required this.pinnedAt,
  });
}
