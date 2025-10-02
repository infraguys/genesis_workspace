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
  // final FolderMembers? folderMembers;

  const FolderItemEntity({
    this.id,
    this.title,
    required this.iconData,
    this.unreadCount = 0,
    this.backgroundColor,
    this.systemType,
    // this.folderMembers,
  });

  FolderItemEntity copyWith({
    int? id,
    String? title,
    IconData? iconData,
    int? unreadCount,
    Color? backgroundColor,
    SystemFolderType? systemType,
    // FolderMembers? folderMembers,
  }) {
    return FolderItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      iconData: iconData ?? this.iconData,
      unreadCount: unreadCount ?? this.unreadCount,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      systemType: systemType ?? this.systemType,
      // folderMembers: folderMembers ?? this.folderMembers,
    );
  }
}

extension FolderItemPresentation on FolderItemEntity {
  String displayTitle(BuildContext context) {
    if (systemType == SystemFolderType.all) return context.t.folders.all;
    return title ?? '';
  }
}
