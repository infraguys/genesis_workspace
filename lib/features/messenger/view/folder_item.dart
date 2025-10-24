import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class FolderItem extends StatefulWidget {
  final FolderItemEntity folder;
  final bool isSelected;
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onOrderPinning;
  final VoidCallback? onDelete;

  FolderItem({
    super.key,
    required this.title,
    required this.folder,
    required this.isSelected,
    required this.icon,
    required this.onTap,
    this.onEdit,
    this.onOrderPinning,
    this.onDelete,
  });

  @override
  State<FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> {
  final popupKey = GlobalKey<CustomPopupState>();

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;

    return CustomPopup(
      key: popupKey,
      isLongPress: true,
      rootNavigator: true,
      arrowColor: theme.colorScheme.surfaceContainer,
      backgroundColor: theme.colorScheme.surfaceContainer,
      content: SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            TextButton(onPressed: widget.onEdit, child: Text(context.t.folders.edit)),
            TextButton(
              onPressed: widget.onOrderPinning,
              child: Text(context.t.folders.orderPinning),
            ),
            TextButton(
              onPressed: widget.onDelete,
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: Text(context.t.folders.delete),
            ),
          ],
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onTap,
        onSecondaryTap: () {
          popupKey.currentState?.show();
        },
        onHover: (bool hover) => setState(() => _isHovered = hover),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UnreadBadge(count: widget.folder.unreadCount),
            SizedBox(height: 40, width: 40, child: widget.icon),
            Tooltip(
              message: widget.title,
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: (widget.isSelected || _isHovered)
                      ? widget.folder.backgroundColor
                      : textColors.text30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
