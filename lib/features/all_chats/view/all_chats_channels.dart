import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/channel_down_expanded_item.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllChatsChannels extends StatefulWidget {
  final Set<int>? filterChannelIds;
  final bool embeddedInParentScroll;

  const AllChatsChannels({
    super.key,
    required this.filterChannelIds,
    this.embeddedInParentScroll = false,
  });

  @override
  State<AllChatsChannels> createState() => _AllChatsChannelsState();
}

class _AllChatsChannelsState extends State<AllChatsChannels> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  late final AnimationController expandController;
  late final Animation<double> expandAnimation;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    expandAnimation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    expandController.value = 1.0;
  }

  @override
  void dispose() {
    scrollController.dispose();
    expandController.dispose();
    super.dispose();
  }

  void toggleExpanded() {
    setState(() => isExpanded = !isExpanded);
    if (isExpanded) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = currentSize(context) > ScreenSize.lTablet;

    return BlocBuilder<ChannelsCubit, ChannelsState>(
      builder: (context, state) {
        final List<ChannelEntity> channels = (widget.filterChannelIds == null)
            ? state.channels
            : state.channels
                  .where((channel) => widget.filterChannelIds!.contains(channel.streamId))
                  .toList();

        if (channels.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.navBar.channels,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    splashRadius: 22,
                    onPressed: toggleExpanded,
                    icon: AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0.0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ],
              ),
            ),
            ClipRect(
              child: SizeTransition(
                sizeFactor: expandAnimation,
                axisAlignment: -1.0,
                child: FadeTransition(
                  opacity: expandAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
                    child: ListView.separated(
                      controller: scrollController,
                      shrinkWrap: true,
                      physics: widget.embeddedInParentScroll
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      itemCount: channels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ChannelEntity channel = channels[index];
                        return ChannelDownExpandedItem(
                          key: ValueKey('channel-${channel.streamId}'),
                          channel: channel,
                          onTap: () async {
                            context.read<AllChatsCubit>().selectChannel(channel: channel);
                            unawaited(
                              context.read<ChannelsCubit>().getChannelTopics(
                                streamId: channel.streamId,
                              ),
                            );
                          },
                          onTopicTap: (topic) {
                            if (isDesktop) {
                              context.read<AllChatsCubit>().selectChannel(
                                channel: channel,
                                topic: topic,
                              );
                            } else {
                              context.pushNamed(
                                Routes.channelChatTopic,
                                pathParameters: {
                                  'channelId': channel.streamId.toString(),
                                  'topicName': topic.name,
                                },
                                extra: {'unreadMessagesCount': topic.unreadMessages.length},
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
