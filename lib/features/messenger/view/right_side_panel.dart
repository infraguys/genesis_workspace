import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final cardColors = Theme.of(context).extension<CardColors>()!;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 315),
      child: Container(
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
                      _Subtitle('Информация о канале'),
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16.0,
                    children: [
                      UserAvatar.group(size: 64),
                      BlocBuilder<ChannelChatCubit, ChannelChatState>(
                        builder: (context, state) {
                          final length = state.channelMembers.length;
                          return Column(
                            crossAxisAlignment: .start,
                            spacing: 10.0,
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
            Padding(
              padding: const .symmetric(horizontal: 8.0),
              child: Row(
                spacing: 8.0,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: .circular(8.0),
                      clipBehavior: .hardEdge,
                      child: Material(
                        shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
                        color: cardColors.base,
                        child: InkWell(
                          onTap: () {},
                          child: SizedBox(
                            height: 56.0,
                            child: Center(child: Assets.icons.call.svg(width: 40)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: .circular(8.0),
                      child: Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(8.0),
                        ),
                        color: cardColors.base,
                        child: InkWell(
                          onTap: () {},
                          child: SizedBox(
                            height: 56.0,
                            child: Center(child: Assets.icons.search.svg(width: 40)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const .symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      _Subtitle('Участники'),
                      IconButton(onPressed: () {}, icon: Icon(Icons.person_add_alt_outlined)),
                    ],
                  ),
                  // Container(
                  //   color: Colors.green,
                  //   height: 40,
                  // ),
                  SizedBox(
                    height: 400,
                    child: BlocBuilder<ChannelChatCubit, ChannelChatState>(
                      builder: (context, state) {
                        return ListView.separated(
                          itemCount: state.channelMembers.length,
                          separatorBuilder: (context, index) => SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final id = state.channelMembers.toList()[index];
                            return _MemberItem(id: id.toString());
                          },
                        );
                      },
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

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}

class _MemberItem extends StatelessWidget {
  const _MemberItem({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final cardColors = Theme.of(context).extension<CardColors>()!;
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
      color: cardColors.base,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? cardColors.active : null,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 65,
          ),
          child: Stack(
            alignment: AlignmentGeometry.centerLeft,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 65,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UserAvatar(
                        // avatarUrl: widget.chat.avatarUrl,
                        // size: currentSize(context) <= ScreenSize.tablet ? 40 : 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User\'s ID - $id',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColors.text100,
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
      ),
    );
  }
}
