import 'package:flutter/material.dart';

class FolderItemEntity {
  final String title;
  final IconData iconData;
  final int unreadCount;
  final Color? backgroundColor;

  const FolderItemEntity({
    required this.title,
    required this.iconData,
    this.unreadCount = 0,
    this.backgroundColor,
  });
}
