import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class GroupChatTile extends StatelessWidget {
  final List<RecipientEntity> members;
  final int unreadCount;
  final bool isPinned;
  final bool isEditPinning;
  final VoidCallback? onTap;
  final Widget? trailingOverride;

  const GroupChatTile({
    super.key,
    required this.members,
    required this.unreadCount,
    this.onTap,
    this.isPinned = false,
    this.isEditPinning = false,
    this.trailingOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String names = members.map((m) => m.fullName).join(', ');
    final int count = members.length;

    final Widget trailing =
        trailingOverride ??
        (isEditPinning
            ? Icon(
                Icons.drag_handle_rounded,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              )
            : UnreadBadge(count: unreadCount));

    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.groups, color: theme.colorScheme.primary),
      title: Row(
        children: [
          Expanded(child: Text(names, overflow: TextOverflow.ellipsis)),
          if (!isEditPinning && isPinned)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.push_pin, size: 12, color: theme.colorScheme.outlineVariant),
            ),
        ],
      ),
      subtitle: Text(
        'Участников: $count',
        style: Theme.of(context).textTheme.labelSmall,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      trailing: trailing,
    );
  }
}
