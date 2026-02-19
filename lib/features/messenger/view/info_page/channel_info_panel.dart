import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/app_progress_indicator.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
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
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Container(
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
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(context.t.messengerView.channelInfo, style: TextStyle(fontSize: 16, fontWeight: .w500)),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Assets.icons.close.svg(),
                    ),
                  ],
                ),
                Row(
                  spacing: 16.0,
                  children: [
                    UserAvatar.group(size: 64),
                    BlocConsumer<ChannelChatCubit, ChannelChatState>(
                      listener: (context, state) {
                        if (state.channelMembers.isNotEmpty) {
                          context.read<ChannelMembersInfoCubit>().getUsers(state.channelMembers);
                        }
                      },
                      builder: (context, state) {
                        final length = state.channelMembers.length;
                        return Flexible(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                state.topic?.name ?? state.channel?.name ?? '',
                                maxLines: 1,
                                style: TextStyle(fontWeight: .w500, fontSize: 20, overflow: TextOverflow.ellipsis),
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
          // Padding(
          //   padding: const .symmetric(horizontal: 8.0),
          //   child: Row(
          //     spacing: 8.0,
          //     children: [
          //       Expanded(
          //         child: ClipRRect(
          //           borderRadius: .circular(8.0),
          //           clipBehavior: .hardEdge,
          //           child: Material(
          //             shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
          //             color: cardColors.base,
          //             child: InkWell(
          //               onTap: () {},
          //               child: SizedBox(
          //                 height: 56.0,
          //                 child: Center(
          //                   child: Assets.icons.call.svg(
          //                     width: 40,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: ClipRRect(
          //           borderRadius: .circular(8.0),
          //           child: Material(
          //             shape: RoundedRectangleBorder(
          //               borderRadius: .circular(8.0),
          //             ),
          //             color: cardColors.base,
          //             child: InkWell(
          //               onTap: () {},
          //               child: SizedBox(
          //                 height: 56.0,
          //                 child: Center(child: Assets.icons.search.svg(width: 40)),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
                          itemCount: state.users.length,
                          separatorBuilder: (context, index) => SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return _MemberItem(user: user);
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
    );
  }
}

class _MemberItem extends StatelessWidget {
  const _MemberItem({super.key, required this.user});

  final DmUserEntity user;

  @override
  Widget build(BuildContext context) {
    final cardColors = Theme.of(context).extension<CardColors>()!;
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Material(
      shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
      color: cardColors.base,
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
                      // size: currentSize(context) <= ScreenSize.tablet ? 40 : 30,
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
                              // fontWeight: currentSize(context) <= ScreenSize.tablet
                              //     ? FontWeight.w500
                              //     : FontWeight.w400,
                            ),
                          ),
                          Text(
                            getPresenceText(context, user),
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textColors.text30,
                              fontSize: 12.0,
                              // fontWeight: currentSize(context) <= ScreenSize.tablet
                              //     ? FontWeight.w500
                              //     : FontWeight.w400,
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
    );
  }
}
