import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/channel_down_expanded_item.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AllChatsChannels extends StatelessWidget {
  const AllChatsChannels({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
            child: BlocBuilder<ChannelsCubit, ChannelsState>(
              builder: (context, channelsState) {
                return ListView.separated(
                  itemCount: channelsState.channels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final channel = channelsState.channels[index];
                    return ChannelDownExpandedItem(
                      channel: channel,
                      onTap: () {
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
