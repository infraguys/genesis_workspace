import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/appbar_container.dart';
import 'package:genesis_workspace/core/widgets/profile_info_tile.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class ChannelInfoPage extends StatefulWidget {
  const ChannelInfoPage({super.key});

  @override
  State<ChannelInfoPage> createState() => _ChannelInfoPageState();
}

class _ChannelInfoPageState extends State<ChannelInfoPage> {
  @override
  void initState() {
    super.initState();

    final chatState = context.read<ChannelChatCubit>().state;
    if (chatState.channelMembers.isNotEmpty) {
      context.read<ChannelMembersInfoCubit>().getUsers(chatState.channelMembers);
    }
  }

  void _openMemberDetails(DmUserEntity user) {
    context.pushNamed(
      Routes.channelInfoMember,
      pathParameters: {
        ...GoRouterState.of(context).pathParameters,
        'userId': user.userId.toString(),
      },
      extra: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Scaffold(
      appBar: AppBarContainer(
        appBar: AppBar(
          title: Text(
            context.t.messengerView.channelInfo,
            style: TextStyle(fontSize: 16, fontWeight: .w500),
          ),
          shape: RoundedRectangleBorder(borderRadius: .all(.zero)),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
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
                      BlocBuilder<ChannelChatCubit, ChannelChatState>(
                        builder: (context, state) {
                          final length = state.channelMembers.length;
                          return Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                state.topic?.name ?? state.channel?.name ?? '',
                                style: TextStyle(
                                  fontWeight: .w500,
                                  fontSize: 20,
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
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
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
                Padding(
                  padding: const .symmetric(horizontal: 8.0),
                  child: SizedBox(
                    height: 400,
                    child: BlocBuilder<ChannelMembersInfoCubit, ChannelMembersInfoState>(
                      builder: (context, state) {
                        if (state is! ChannelMembersLoadedState) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView.separated(
                          itemCount: state.users.length,
                          separatorBuilder: (context, index) => SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return _MemberItem(
                              user: user,
                              onTap: () => _openMemberDetails(user),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

class ChannelMemberDetailsPage extends StatelessWidget {
  const ChannelMemberDetailsPage({super.key, required this.user});

  final DmUserEntity user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColors = theme.extension<IconColors>()!;

    return Scaffold(
      appBar: AppBarContainer(
        appBar: AppBar(
          title: Text(
            context.t.profilePersonalInfo.title,
            style: TextStyle(fontSize: 16, fontWeight: .w500),
          ),
          shape: RoundedRectangleBorder(borderRadius: .all(.zero)),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: ListView(
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
        ),
      ),
    );
  }
}
