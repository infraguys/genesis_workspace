import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelTopics extends StatefulWidget {
  final ChannelEntity? channel;
  const ChannelTopics({super.key, this.channel});

  @override
  State<ChannelTopics> createState() => _ChannelTopicsState();
}

class _ChannelTopicsState extends State<ChannelTopics> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      height: MediaQuery.sizeOf(context).height,
      child: BlocBuilder<ChannelsCubit, ChannelsState>(
        builder: (context, state) {
          if (widget.channel == null) {
            return SizedBox.expand();
          }
          return Skeletonizer(
            enabled: state.pendingTopicsId == widget.channel!.streamId,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                itemCount: widget.channel!.topics.isEmpty ? 3 : widget.channel!.topics.length + 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: Text(
                        widget.channel!.topics.isEmpty ? 'Loading...' : context.t.allMessages,
                      ),
                      leading: Icon(Icons.topic),
                      trailing: widget.channel!.unreadMessages.isNotEmpty
                          ? Text("${widget.channel!.unreadMessages.length}")
                          : null,
                      onTap: state.pendingTopicsId != widget.channel!.streamId
                          ? () async {
                              if (currentSize(context) > ScreenSize.lTablet) {
                                context.read<ChannelsCubit>().openTopic(channel: widget.channel!);
                              } else {
                                context.pushNamed(
                                  Routes.channelChat,
                                  extra: ChannelChatExtra(channel: widget.channel!),
                                );
                              }
                            }
                          : null,
                    );
                  } else {
                    index--;
                  }
                  TopicEntity? topic;
                  Widget? trailing;
                  if (widget.channel!.topics.isNotEmpty) {
                    topic = widget.channel!.topics[index];
                    trailing = topic.unreadMessages.isNotEmpty
                        ? Text("${topic.unreadMessages.length}")
                        : null;
                  }
                  return ListTile(
                    title: Text(widget.channel!.topics.isEmpty ? 'Loading...' : topic!.name),
                    leading: Icon(Icons.topic),
                    trailing: trailing,
                    onTap: state.pendingTopicsId != widget.channel!.streamId
                        ? () async {
                            if (currentSize(context) > ScreenSize.lTablet) {
                              context.read<ChannelsCubit>().openTopic(
                                channel: widget.channel!,
                                topic: widget.channel!.topics[index],
                              );
                            } else {
                              context.pushNamed(
                                Routes.channelChat,
                                extra: ChannelChatExtra(
                                  channel: widget.channel!,
                                  topicEntity: topic!,
                                ),
                              );
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
