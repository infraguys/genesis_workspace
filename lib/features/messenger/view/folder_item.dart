import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class FolderItem extends StatefulWidget {
  final FolderItemEntity folder;
  final bool isSelected;
  final String title;
  final Widget? icon;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onOrderPinning;
  final VoidCallback? onDelete;

  FolderItem({
    super.key,
    required this.title,
    required this.folder,
    required this.isSelected,
    this.icon,
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
      isLongPress: currentSize(context) <= ScreenSize.tablet,
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
        child: currentSize(context) > ScreenSize.tablet
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UnreadBadge(count: widget.folder.unreadMessages.length),
                  SizedBox(height: 40, width: 40, child: widget.icon),
                  Tooltip(
                    message: widget.title,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: (widget.isSelected || _isHovered) ? widget.folder.backgroundColor : textColors.text30,
                      ),
                    ),
                  ),
                ],
              )
            : Material(
                type: MaterialType.transparency,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 4),
                    decoration: BoxDecoration(
                      border: widget.isSelected
                          ? Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: widget.isSelected ? textColors.text100 : textColors.text30,
                          ),
                        ),
                        UnreadBadge(count: widget.folder.unreadMessages.length),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
