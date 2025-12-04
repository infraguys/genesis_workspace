import 'package:genesis_workspace/domain/all_chats/entities/folder_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_item_dto.g.dart';

@JsonSerializable()
class FolderItemDto {
  @JsonKey(name: "uuid")
  final String uuid;
  @JsonKey(name: "folder_uuid")
  final String folderUuid;
  @JsonKey(name: "chat_id")
  final int chatId;
  @JsonKey(name: "order_index")
  final int? orderIndex;
  @JsonKey(name: "pinned_at")
  final String? pinnedAt;
  @JsonKey(name: "created_at")
  final String createdAt;
  @JsonKey(name: "updated_at")
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

  factory FolderItemDto.fromJson(Map<String, dynamic> json) => _$FolderItemDtoFromJson(json);

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

@JsonSerializable()
class CreateFolderItemRequest {
  @JsonKey(name: "chat_id")
  final int chatId;
  @JsonKey(name: "order_index")
  final int? orderIndex;

  CreateFolderItemRequest({required this.chatId, this.orderIndex});

  Map<String, dynamic> toJson() => _$CreateFolderItemRequestToJson(this);
}

@JsonSerializable()
class UpdateFolderItemRequest {
  @JsonKey(name: "order_index")
  final int? orderIndex;

  UpdateFolderItemRequest({this.orderIndex});

  Map<String, dynamic> toJson() => _$UpdateFolderItemRequestToJson(this);
}
