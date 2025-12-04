class FolderItem {
  final String uuid;
  final String folderUuid;
  final int chatId;
  final int? orderIndex;
  final DateTime? pinnedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FolderItem({
    required this.uuid,
    required this.folderUuid,
    required this.chatId,
    this.orderIndex,
    this.pinnedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPinned => pinnedAt != null;
}
