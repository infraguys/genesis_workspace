import 'package:genesis_workspace/domain/all_chats/entities/folder_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_item_dto.g.dart';

@JsonSerializable()
class FolderItemDto {
  FolderItemDto({
    required this.uuid,
    required this.folderUuid,
    required this.chatId,
    this.orderIndex,
    this.pinnedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @JsonKey(name: 'uuid')
  final String uuid;
  @JsonKey(name: 'folder_uuid')
  final String folderUuid;
  @JsonKey(name: 'chat_id')
  final int chatId;
  @JsonKey(name: 'order_index')
  final int? orderIndex;
  @JsonKey(name: 'pinned_at', fromJson: DateTime.tryParse)
  final DateTime? pinnedAt;
  @JsonKey(name: 'created_at', fromJson: DateTime.tryParse)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: DateTime.tryParse)
  final DateTime? updatedAt;

  factory FolderItemDto.fromJson(Map<String, dynamic> json) => _$FolderItemDtoFromJson(json);

  FolderItemEntity toEntity() => FolderItemEntity(
    uuid: uuid,
    folderUuid: folderUuid,
    chatId: chatId,
    orderIndex: orderIndex,
    pinnedAt: pinnedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
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
