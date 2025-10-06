import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UserTile extends StatelessWidget {
  final DmUserEntity user;
  final bool isPinned;
  final bool isEditPinning;
  final void Function() onTap;

  /// Если задан, будет использован вместо дефолтного trailing.
  final Widget? trailingOverride;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.isPinned,
    this.isEditPinning = false,
    this.trailingOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lastSeen = DateTime.fromMillisecondsSinceEpoch((user.presenceTimestamp * 1000).toInt());

    final Widget trailing =
        trailingOverride ??
        (isEditPinning
            ? Icon(
                Icons.drag_handle_rounded,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              )
            : UnreadBadge(count: user.unreadMessages.length));

    return ListTile(
      onTap: onTap,
      leading: UserAvatar(avatarUrl: user.avatarUrl),
      title: Row(
        children: [
          Expanded(child: Text(user.fullName, overflow: TextOverflow.ellipsis)),
          if (!isEditPinning && isPinned)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.push_pin_rounded, size: 12),
            ),
        ],
      ),
      subtitle: Text(
        isJustNow(lastSeen)
            ? context.t.wasOnlineJustNow
            : context.t.wasOnline(time: timeAgoText(context, lastSeen)),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
