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
