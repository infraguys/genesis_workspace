import 'dart:ui';

import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_dto.g.dart';

@JsonSerializable(createToJson: false)
class FolderDto {
  FolderDto({
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.backgroundColorValue,
    required this.unreadMessages,
    required this.systemType,
  });

  @JsonKey(name: 'uuid')
  final String uuid;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'background_color_value')
  final int backgroundColorValue;
  @JsonKey(name: 'unread_messages')
  final List<int> unreadMessages;
  @JsonKey(name: 'system_type')
  final FolderSystemType systemType;

  factory FolderDto.fromJson(Map<String, dynamic> json) => _$FolderDtoFromJson(json);

  FolderEntity toEntity() => FolderEntity(
    uuid: uuid,
    createdAt: createdAt,
    updatedAt: updatedAt,
    title: title,
    backgroundColor: Color(backgroundColorValue),
    unreadMessages: unreadMessages,
    systemType: systemType,
    folderItems: {},
  );
}
