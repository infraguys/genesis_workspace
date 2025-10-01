import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

enum SystemFolderType { all }

class FolderItemEntity {
  final int? id;
  final String? title;
  final IconData iconData;
  final int unreadCount;
  final Color? backgroundColor;
  final SystemFolderType? systemType;

  const FolderItemEntity({
    this.id,
    this.title,
    required this.iconData,
    this.unreadCount = 0,
    this.backgroundColor,
    this.systemType,
  });
}

extension FolderItemPresentation on FolderItemEntity {
  String displayTitle(BuildContext context) {
    if (systemType == SystemFolderType.all) return context.t.folders.all;
    return title ?? '';
  }
}
