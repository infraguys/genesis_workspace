import 'package:genesis_workspace/domain/all_chats/entities/folder_item.dart';
class FolderItemDto {
  final String uuid;
  final String folderUuid;
  final int chatId;
  final int? orderIndex;
  final String? pinnedAt;
  final String createdAt;
  final String updatedAt;

  FolderItemDto({
    required this.uuid,
    required this.folderUuid,
    required this.chatId,
    this.orderIndex,
    this.pinnedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderItemDto.fromJson(Map<String, dynamic> json) => FolderItemDto(
        uuid: json['uuid'] as String,
        folderUuid: json['folder_uuid'] as String,
        chatId: json['chat_id'] as int,
        orderIndex: json['order_index'] as int?,
        pinnedAt: json['pinned_at'] as String?,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'folder_uuid': folderUuid,
        'chat_id': chatId,
        'order_index': orderIndex,
        'pinned_at': pinnedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  FolderItem toEntity() => FolderItem(
        uuid: uuid,
        folderUuid: folderUuid,
        chatId: chatId,
        orderIndex: orderIndex,
        pinnedAt: pinnedAt != null ? DateTime.tryParse(pinnedAt!) : null,
        createdAt: DateTime.tryParse(createdAt),
        updatedAt: DateTime.tryParse(updatedAt),
      );
}

class CreateFolderItemRequest {
  final int chatId;
  final int? orderIndex;

  CreateFolderItemRequest({required this.chatId, this.orderIndex});

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        if (orderIndex != null) 'order_index': orderIndex,
      };
}

class UpdateFolderItemRequest {
  final int? orderIndex;

  UpdateFolderItemRequest({this.orderIndex});

  Map<String, dynamic> toJson() => {
        if (orderIndex != null) 'order_index': orderIndex,
      };
}
