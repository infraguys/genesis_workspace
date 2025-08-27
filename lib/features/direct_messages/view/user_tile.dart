import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class UserTile extends StatelessWidget {
  final DmUserEntity user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
      builder: (context, state) {
        Widget? subtitle;

        if (state.typingUsers.contains(user.userId)) {
          subtitle = Text("${context.t.typing}...");
        } else if (user.presenceStatus == PresenceStatus.active) {
          subtitle = Row(
            spacing: 8,
            children: [
              Text(context.t.online, style: theme.textTheme.labelSmall),
              const Icon(Icons.circle, color: Colors.green, size: 10),
            ],
          );
        } else {
          final lastSeen = DateTime.fromMillisecondsSinceEpoch(
            (user.presenceTimestamp * 1000).toInt(),
          );
          final timeAgo = timeAgoText(context, lastSeen);

          subtitle = Text(
            isJustNow(lastSeen) ? context.t.wasOnlineJustNow : context.t.wasOnline(time: timeAgo),
            style: theme.textTheme.labelSmall,
          );
        }
        return ListTile(
          onTap: () {
            // context.go('/direct-messages/${user.userId}');
            if (currentSize(context) > ScreenSize.lTablet) {
              context.read<DirectMessagesCubit>().selectUserChat(
                userId: user.userId,
                unreadMessagesCount: user.unreadMessages.length,
              );
              // context.setDmUserIdInUrl(user.userId);
              // SystemNavigator.routeInformationUpdated(
              //   uri: Uri(path: "${}"),
              // );
            } else {
              // Мобильная навигация на подроут /direct-messages/:userId
              context.pushNamed(
                Routes.chat,
                pathParameters: {'userId': user.userId.toString()},
                extra: {'unreadMessagesCount': user.unreadMessages.length},
              );
            }
          },
          title: Text(user.fullName, overflow: TextOverflow.ellipsis),
          subtitle: subtitle,
          leading: UserAvatar(avatarUrl: user.avatarUrl),
          trailing: Badge.count(
            count: user.unreadMessages.length,
            isLabelVisible: user.unreadMessages.isNotEmpty,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        );
      },
    );
  }
}
