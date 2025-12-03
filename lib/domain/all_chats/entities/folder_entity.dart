import 'dart:ui';

import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_dto.dart';

class CreateFolderEntity {
  final String title;
  final Color backgroundColor;
  final FolderSystemType systemType;

  CreateFolderEntity({required this.title, required this.backgroundColor, required this.systemType});

  CreateFolderDto toDto() => CreateFolderDto(
    title: title,
    backgroundColorValue: backgroundColor.toARGB32(),
    systemType: systemType,
  );
}

class UpdateFolderEntity {
  final String uuid;
  final String? title;
  final Color? backgroundColor;

  UpdateFolderEntity({required this.uuid, this.title, this.backgroundColor});

  UpdateFolderDto toDto() => UpdateFolderDto(
    title: title,
    backgroundColorValue: backgroundColor?.toARGB32(),
  );
}

class DeleteFolderEntity {
  final String folderId;

  DeleteFolderEntity({required this.folderId});
}

class FolderEntity {
  final int? id;
  final String uuid;
  final String createdAt;
  final String updatedAt;
  final String title;
  final Color backgroundColor;
  final List<int> unreadMessages;
  final FolderSystemType systemType;

  FolderEntity({
    this.id,
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.backgroundColor,
    required this.unreadMessages,
    required this.systemType,
  });

  FolderEntity copyWith({
    int? id,
    String? uuid,
    String? createdAt,
    String? updatedAt,
    String? title,
    Color? backgroundColor,
    List<int>? unreadMessages,
    FolderSystemType? systemType,
    int? organizationId,
  }) => FolderEntity(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title ?? this.title,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    unreadMessages: unreadMessages ?? this.unreadMessages,
    systemType: systemType ?? this.systemType,
  );
}
