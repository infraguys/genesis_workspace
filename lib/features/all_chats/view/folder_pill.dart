import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class FolderPill extends StatelessWidget {
  final FolderItemEntity folder;
  final bool isSelected;
  final void Function()? onTap;
  final void Function()? onEdit;
  final void Function()? onEditPinning;
  final void Function()? onDelete;
  const FolderPill({
    super.key,
    required this.isSelected,
    this.onTap,
    required this.folder,
    this.onEdit,
    this.onEditPinning,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final Color backgroundColor = isSelected
        ? folder.backgroundColor?.withValues(alpha: 0.1) ?? schema.primary.withValues(alpha: 0.2)
        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final Color foregroundColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        child: InkWell(
          hoverColor:
              folder.backgroundColor?.withValues(alpha: 0.1) ??
              schema.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          onTap: onTap,
          onSecondaryTapDown: (details) {
            if (folder.systemType != null) return;
            _showContextMenu(context, details.globalPosition);
          },
          onLongPress: () {
            if (folder.systemType != null) return;
            final box = context.findRenderObject() as RenderBox?;
            final pos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
            _showContextMenu(context, pos);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(folder.iconData, size: 18, color: folder.backgroundColor),
                const SizedBox(width: 8),
                Text(folder.displayTitle(context), style: TextStyle(color: foregroundColor)),
                if (folder.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: schema.secondary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      folder.unreadCount.toString(),
                      style: TextStyle(
                        color: isSelected ? schema.onPrimary : schema.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    if (onEdit == null && onDelete == null && onEditPinning == null) return;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        if (onEdit != null) PopupMenuItem(value: 'edit', child: Text(context.t.folders.edit)),
        if (onEditPinning != null) PopupMenuItem(value: 'editPinning', child: Text("Edit pinning")),
        if (onDelete != null) PopupMenuItem(value: 'delete', child: Text(context.t.folders.delete)),
      ],
    );
    if (selected == 'edit') {
      onEdit?.call();
    } else if (selected == 'delete') {
      onDelete?.call();
    } else if (selected == 'editPinning') {
      onEditPinning?.call();
    }
  }
}
