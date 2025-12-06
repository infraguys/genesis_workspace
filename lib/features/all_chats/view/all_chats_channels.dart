import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/channel_compact_item.dart';
import 'package:genesis_workspace/features/all_chats/view/channel_down_expanded_item.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllChatsChannels extends StatefulWidget {
  final Set<int>? filterChannelIds;
  final FolderItemEntity selectedFolder;
  final bool embeddedInParentScroll;
  final bool isEditPinning;

  const AllChatsChannels({
    super.key,
    required this.filterChannelIds,
    required this.selectedFolder,
    this.embeddedInParentScroll = false,
    required this.isEditPinning,
  });

  @override
  State<AllChatsChannels> createState() => _AllChatsChannelsState();
}

class _AllChatsChannelsState extends State<AllChatsChannels> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  late final AnimationController expandController;
  late final Animation<double> expandAnimation;
  bool isExpanded = true;
  List<ChannelEntity>? optimisticChannels;
  bool isReorderingInProgress = false;

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
      buildWhen: (_, _) => !isReorderingInProgress,
      builder: (context, state) {
        final List<ChannelEntity> baseList = (widget.filterChannelIds == null || widget.selectedFolder.id == 0)
            ? [...state.channels]
            : [
                ...state.channels,
              ].where((channel) => widget.filterChannelIds!.contains(channel.streamId)).toList();

        final pinnedChats = widget.selectedFolder.pinnedChats
            // .where((chat) => chat.type == PinnedChatType.channel)
            .toList();
        final Map<int, PinnedChatEntity> pinnedByChatId = {
          for (final pinned in pinnedChats) pinned.chatId: pinned,
        };

        int compareByOrderAndPinnedAt(PinnedChatEntity? a, PinnedChatEntity? b) {
          final bool aPinned = a != null;
          final bool bPinned = b != null;
          if (aPinned && !bPinned) return -1;
          if (!aPinned && bPinned) return 1;
          if (!aPinned && !bPinned) return 0;

          final int? aOrder = a!.orderIndex;
          final int? bOrder = b!.orderIndex;

          if (aOrder != null && bOrder != null) {
            if (aOrder != bOrder) return aOrder.compareTo(bOrder);
            // return b.pinnedAt.compareTo(a.pinnedAt);
          }
          if (aOrder != null && bOrder == null) return -1;
          if (aOrder == null && bOrder != null) return 1;

          // return b.pinnedAt.compareTo(a.pinnedAt);
          return 1;
        }

        List<ChannelEntity> filtered;
        if (widget.isEditPinning) {
          filtered = baseList.where((c) => pinnedByChatId.containsKey(c.streamId)).toList()
            ..sort(
              (a, b) => compareByOrderAndPinnedAt(pinnedByChatId[a.streamId], pinnedByChatId[b.streamId]),
            );
        } else {
          if (pinnedByChatId.isEmpty) {
            filtered = baseList;
          } else {
            final Map<int, int> originalIndexById = {
              for (int i = 0; i < baseList.length; i++) baseList[i].streamId: i,
            };
            filtered = List<ChannelEntity>.from(baseList);
            filtered.sort((a, b) {
              final int pinnedCompare = compareByOrderAndPinnedAt(
                pinnedByChatId[a.streamId],
                pinnedByChatId[b.streamId],
              );
              if (pinnedCompare != 0) return pinnedCompare;
              return originalIndexById[a.streamId]!.compareTo(originalIndexById[b.streamId]!);
            });
          }
        }

        final List<ChannelEntity> channels = optimisticChannels ?? filtered;

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
            SizeTransition(
              sizeFactor: expandAnimation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: expandAnimation,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
                  child: widget.isEditPinning
                      ? ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          shrinkWrap: true,
                          physics: widget.embeddedInParentScroll
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          itemCount: channels.length,
                          onReorder: (int oldIndex, int newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final List<ChannelEntity> local = List<ChannelEntity>.from(
                              optimisticChannels ?? channels,
                            );
                            final ChannelEntity moved = local.removeAt(oldIndex);
                            local.insert(newIndex, moved);

                            setState(() {
                              isReorderingInProgress = true;
                              optimisticChannels = local;
                            });

                            final int movedChatId = moved.streamId;
                            final int? previousChatId = (newIndex - 1) >= 0 ? local[newIndex - 1].streamId : null;
                            final int? nextChatId = (newIndex + 1) < local.length ? local[newIndex + 1].streamId : null;

                            try {
                              await context.read<AllChatsCubit>().reorderPinnedChats(
                                folderId: widget.selectedFolder.id ?? 0,
                                movedChatId: movedChatId,
                                previousChatId: previousChatId,
                                nextChatId: nextChatId,
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isReorderingInProgress = false;
                                  optimisticChannels = null;
                                });
                              }
                            }
                          },
                          proxyDecorator: (child, index, animation) => Material(elevation: 3, child: child),
                          itemBuilder: (context, index) {
                            final ChannelEntity channel = channels[index];
                            final PinnedChatEntity? pinned = pinnedByChatId[channel.streamId];
                            return KeyedSubtree(
                              key: ValueKey<int>(channel.streamId),
                              child: ChannelCompactItem(
                                key: ValueKey('channel-compact-${channel.streamId}'),
                                channel: channel,
                                isPinned: pinned != null,
                                trailingOverride: ReorderableDragStartListener(
                                  index: index,
                                  child: Icon(
                                    Icons.drag_handle_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.separated(
                          controller: scrollController,
                          shrinkWrap: true,
                          physics: widget.embeddedInParentScroll
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          itemCount: channels.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final ChannelEntity channel = channels[index];
                            final PinnedChatEntity? pinned = pinnedByChatId[channel.streamId];
                            return ChannelDownExpandedItem(
                              key: ValueKey('channel-${channel.streamId}'),
                              channel: channel,
                              isPinned: pinned != null,
                              // pinnedChatId: pinned?.id,
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
          ],
        );
      },
    );
  }
}
