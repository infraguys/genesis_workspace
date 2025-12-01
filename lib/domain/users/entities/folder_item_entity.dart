import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

enum SystemFolderType { all }

class FolderItemEntity {
  final int? id;
  final String? title;
  final IconData iconData;
  final Set<int> unreadMessages;
  final Color? backgroundColor;
  final SystemFolderType? systemType;
  final List<PinnedChatEntity> pinnedChats;
  final int organizationId;

  const FolderItemEntity({
    this.id,
    this.title,
    required this.iconData,
    this.unreadMessages = const <int>{},
    this.backgroundColor,
    this.systemType,
    required this.pinnedChats,
    required this.organizationId,
  });

  FolderItemEntity copyWith({
    int? id,
    String? title,
    IconData? iconData,
    Set<int>? unreadMessages,
    Color? backgroundColor,
    SystemFolderType? systemType,
    List<PinnedChatEntity>? pinnedChats,
    int? organizationId,
  }) {
    return FolderItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      iconData: iconData ?? this.iconData,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      systemType: systemType ?? this.systemType,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      organizationId: organizationId ?? this.organizationId,
    );
  }

  int get unreadCount => unreadMessages.length;
}

extension FolderItemPresentation on FolderItemEntity {
  String displayTitle(BuildContext context) {
    if (systemType == SystemFolderType.all) return context.t.folders.all;
    return title ?? '';
  }
}
