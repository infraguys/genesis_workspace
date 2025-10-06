import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UserTile extends StatelessWidget {
  final DmUserEntity user;
  final bool isPinned;
  final void Function() onTap;
  const UserTile({super.key, required this.user, required this.onTap, required this.isPinned});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lastSeen = DateTime.fromMillisecondsSinceEpoch((user.presenceTimestamp * 1000).toInt());
    final timeAgo = timeAgoText(context, lastSeen);

    return ListTile(
      onTap: onTap,
      title: Row(
        children: [
          Text(user.fullName, overflow: TextOverflow.ellipsis),
          if (isPinned) Icon(Icons.push_pin_rounded, size: 12),
        ],
      ),
      subtitle: Text(
        isJustNow(lastSeen) ? context.t.wasOnlineJustNow : context.t.wasOnline(time: timeAgo),
        style: theme.textTheme.labelSmall,
      ),
      leading: UserAvatar(avatarUrl: user.avatarUrl),
      trailing: UnreadBadge(count: user.unreadMessages.length),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
