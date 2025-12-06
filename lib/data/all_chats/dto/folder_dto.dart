import 'dart:ui';

import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_dto.g.dart';

@JsonSerializable()
class CreateFolderDto {
  final String title;

  @JsonKey(name: 'background_color_value')
  final int backgroundColorValue;

  @JsonKey(name: 'unread_messages')
  final List<int> unreadMessages;

  @JsonKey(name: 'system_type')
  final FolderSystemType systemType;

  const CreateFolderDto({
    required this.title,
    required this.backgroundColorValue,
    this.unreadMessages = const <int>[],
    required this.systemType,
  });

  factory CreateFolderDto.fromJson(Map<String, dynamic> json) => _$CreateFolderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateFolderDtoToJson(this);
}

@JsonSerializable()
class UpdateFolderDto {
  final String? title;

  @JsonKey(name: 'background_color_value')
  final int? backgroundColorValue;

  const UpdateFolderDto({
    this.title,
    this.backgroundColorValue,
  });

  Map<String, dynamic> toJson() => _$UpdateFolderDtoToJson(this);
}

@JsonSerializable()
class FolderDto {
  final String uuid;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final String title;
  @JsonKey(name: 'background_color_value')
  final int backgroundColorValue;
  @JsonKey(name: 'unread_messages')
  final List<int> unreadMessages;
  @JsonKey(name: 'system_type')
  final FolderSystemType systemType;

  FolderDto({
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.backgroundColorValue,
    required this.unreadMessages,
    required this.systemType,
  });

  factory FolderDto.fromJson(Map<String, dynamic> json) => _$FolderDtoFromJson(json);

  FolderEntity toEntity() => FolderEntity(
    uuid: uuid,
    createdAt: createdAt,
    updatedAt: updatedAt,
    title: title,
    backgroundColor: Color(backgroundColorValue),
    unreadMessages: unreadMessages,
    systemType: systemType,
  );
}
