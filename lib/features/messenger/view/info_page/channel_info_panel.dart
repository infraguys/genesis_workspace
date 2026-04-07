import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/app_progress_indicator.dart';
import 'package:genesis_workspace/core/widgets/profile_info_tile.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel/info_panel_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ChannelInfoPanel extends StatefulWidget {
  const ChannelInfoPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<ChannelInfoPanel> createState() => _ChannelInfoPanelState();
}

class _ChannelInfoPanelState extends State<ChannelInfoPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChannelChatCubit>().state;
      if (chat.channelMembers.isNotEmpty) {
        context.read<ChannelMembersInfoCubit>().getUsers(chat.channelMembers);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/member-details':
              final user = settings.arguments as DmUserEntity;
              return MaterialPageRoute(
                builder: (pageContext) => _ChannelMemberDetailsPage(
                  user: user,
                  onClose: widget.onClose,
                ),
                settings: settings,
              );
            default:
              return MaterialPageRoute(
                builder: (pageContext) => _ChannelMembersPage(
                  onClose: widget.onClose,
                  onOpenMemberDetails: (itemContext, user) {
                    Navigator.of(itemContext).pushNamed('/member-details', arguments: user);
                  },
                ),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}

class _ChannelMembersPage extends StatelessWidget {
  const _ChannelMembersPage({
    required this.onClose,
    required this.onOpenMemberDetails,
  });

  final VoidCallback onClose;
  final void Function(BuildContext context, DmUserEntity user) onOpenMemberDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final isMobile = currentSize(context) <= .tablet;

    return Scaffold(
      backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          context.t.messengerView.channelInfo,
          style: TextStyle(fontSize: 16, fontWeight: .w500),
        ),
        actions: [
          IconButton(
            onPressed: onClose,
            icon: Assets.icons.close.svg(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: .circular(12.0),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: .start,
          spacing: 20.0,
          children: [
            Padding(
              padding: const .only(left: 20.0, right: 20.0, top: 20.0),
              child: Column(
                spacing: 12,
                children: [
                  Row(
                    spacing: 16.0,
                    children: [
                      UserAvatar.group(size: 64),
                      BlocConsumer<ChannelChatCubit, ChannelChatState>(
                        listenWhen: (prev, current) {
                          final panelStatus = context.read<InfoPanelCubit>().state.status;
                          final prevLength = prev.channelMembers.length;
                          final currentLength = current.channelMembers.length;
                          return panelStatus == .channelInfo && (prevLength != currentLength);
                        },
                        listener: (context, state) {
                          final chat = context.read<ChannelChatCubit>().state;
                          if (chat.channelMembers.isNotEmpty) {
                            context.read<ChannelMembersInfoCubit>().getUsers(chat.channelMembers);
                          }
                        },
                        builder: (context, state) {
                          final length = state.channelMembers.length;
                          return Flexible(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  state.channel?.name ?? '',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: .w500,
                                    fontSize: 20,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  context.t.group.membersCount(count: length),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: textColors.text30,
                                    fontWeight: .w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const .symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          context.t.group.members,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        IconButton(onPressed: () {}, icon: Assets.icons.personAdd.svg(width: 25)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const .symmetric(horizontal: 8.0),
                      child: BlocBuilder<ChannelMembersInfoCubit, ChannelMembersInfoState>(
                        builder: (context, state) {
                          if (state is! ChannelMembersLoadedState) {
                            return AppProgressIndicator();
                          }
                          return ListView.separated(
                            itemCount: state.channelUsers.length,
                            separatorBuilder: (context, index) => SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final user = state.channelUsers[index];
                              return _MemberItem(
                                user: user,
                                onTap: () => onOpenMemberDetails(context, user),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelMemberDetailsPage extends StatelessWidget {
  const _ChannelMemberDetailsPage({
    required this.user,
    required this.onClose,
  });

  final DmUserEntity user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColors = Theme.of(context).extension<IconColors>()!;
    final isMobile = currentSize(context) <= .tablet;

    return Scaffold(
      backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Assets.icons.arrowLeft.svg(
            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
          ),
        ),
        title: Text(
          context.t.profilePersonalInfo.title,
          style: TextStyle(fontSize: 16, fontWeight: .w500),
        ),
        actions: [
          IconButton(
            onPressed: onClose,
            icon: Assets.icons.close.svg(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: .circular(12.0),
          color: theme.colorScheme.surface,
        ),
        child: _ChannelMemberDetails(user: user),
      ),
    );
  }
}

class _MemberItem extends StatelessWidget {
  const _MemberItem({required this.user, required this.onTap});

  final DmUserEntity user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColors = Theme.of(context).extension<CardColors>()!;
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Material(
      shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
      color: cardColors.base,
      child: InkWell(
        borderRadius: .circular(8.0),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 65),
          child: Stack(
            alignment: .centerLeft,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 65),
                child: Padding(
                  padding: const .symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: .center,
                    children: [
                      UserAvatar(
                        avatarUrl: user.avatarUrl,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              user.fullName,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColors.text100,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              getPresenceText(context, user),
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColors.text30,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelMemberDetails extends StatelessWidget {
  const _ChannelMemberDetails({required this.user});

  final DmUserEntity user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColors = theme.extension<IconColors>()!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Row(
          children: [
            UserAvatar(avatarUrl: user.avatarUrl, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getPresenceText(context, user),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
        const SizedBox(height: 12),
        ProfileInfoTile(
          label: context.t.profilePersonalInfo.userId,
          value: user.userId.toString(),
          icon: Assets.icons.alternateEmail.svg(
            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
          ),
        ),
        const SizedBox(height: 12),
        ProfileInfoTile(
          label: context.t.email,
          value: user.email,
          icon: SizedBox(
            width: 32,
            child: Assets.icons.mail.svg(
              width: 24,
              colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ProfileInfoTile(
          label: context.t.profilePersonalInfo.timezone,
          value: user.timezone,
          icon: Assets.icons.schedule.svg(
            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
          ),
        ),
        const SizedBox(height: 12),
        ProfileInfoTile(
          label: context.t.profilePersonalInfo.teamAndPosition,
          value: user.jobTitle,
          icon: Assets.icons.businessCenter.svg(
            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
          ),
        ),
        const SizedBox(height: 12),
        ProfileInfoTile(
          label: context.t.profilePersonalInfo.manager,
          value: user.bossName,
          icon: Assets.icons.handshake.svg(
            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
          ),
        ),
      ],
    );
  }
}
