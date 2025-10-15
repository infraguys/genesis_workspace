import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class GroupChatTile extends StatelessWidget {
  final List<RecipientEntity> members;
  final int unreadCount;
  final VoidCallback? onTap;

  const GroupChatTile({super.key, required this.members, this.onTap, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String names = members.map((m) => m.fullName).join(', ');
    final int count = members.length;

    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.groups, color: theme.colorScheme.primary),
      title: Text(names, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        'Участников: $count',
        style: Theme.of(context).textTheme.labelSmall,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      trailing: UnreadBadge(count: unreadCount),
    );
  }
}
