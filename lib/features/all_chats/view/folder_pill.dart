import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

class FolderPill extends StatelessWidget {
  final FolderItemEntity folder;
  final bool isSelected;
  final void Function()? onTap;
  const FolderPill({super.key, required this.isSelected, this.onTap, required this.folder});

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final Color backgroundColor = isSelected
        ? folder.backgroundColor?.withValues(alpha: 0.1) ?? schema.primary.withValues(alpha: 0.2)
        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final Color borderColor = isSelected ? schema.primary : Colors.transparent;
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
          // customBorder: const StadiumBorder(),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(folder.iconData, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
                Text(folder.title, style: TextStyle(color: foregroundColor)),
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
}
