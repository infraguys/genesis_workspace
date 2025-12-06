class PinnedChatEntity {
  final String folderItemUuid;
  final String folderUuid;
  final int chatId;
  final int? orderIndex;
  final DateTime? pinnedAt;
  final DateTime? updatedAt;

  PinnedChatEntity({
    required this.folderItemUuid,
    required this.folderUuid,
    required this.chatId,
    this.orderIndex,
    this.pinnedAt,
    this.updatedAt,
  });
}
