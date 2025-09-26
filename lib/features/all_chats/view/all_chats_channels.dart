import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/channel_down_expanded_item.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AllChatsChannels extends StatefulWidget {
  final List<ChannelEntity> channels;
  final Set<int>? filterChannelIds;
  const AllChatsChannels({super.key, required this.filterChannelIds, required this.channels});

  @override
  State<AllChatsChannels> createState() => _AllChatsChannelsState();
}

class _AllChatsChannelsState extends State<AllChatsChannels> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsCubit, ChannelsState>(
      builder: (context, state) {
        final channels = widget.filterChannelIds == null
            ? state.channels
            : state.channels
                  .where((channel) => widget.filterChannelIds!.contains(channel.streamId))
                  .toList();
        if (channels.isEmpty) {
          return SizedBox.shrink();
        }
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.t.navBar.channels,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: channels.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                        context.read<AllChatsCubit>().selectChannel(channel: channel, topic: topic);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
