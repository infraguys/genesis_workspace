import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelsView extends StatefulWidget {
  const ChannelsView({super.key});

  @override
  State<ChannelsView> createState() => ChannelsViewState();
}

class ChannelsViewState extends State<ChannelsView> {
  late final Future _future;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _future = context.read<ChannelsCubit>().getChannels();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Channels')),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Some error..."));
            }
          }
          return BlocBuilder<ChannelsCubit, ChannelsState>(
            builder: (context, state) {
              return BlocBuilder<MessagesCubit, MessagesState>(
                builder: (context, messagesState) {
                  context.read<ChannelsCubit>().setUnreadMessages(messagesState.unreadMessages);
                  return ListView.builder(
                    itemCount: state.channels.length,
                    itemBuilder: (context, index) {
                      final channel = state.channels[index];
                      return ExpansionTile(
                        title: Text(
                          channel.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: channel.description.isNotEmpty ? Text(channel.description) : null,
                        leading: Badge.count(
                          count: channel.unreadMessages.length,
                          isLabelVisible: channel.unreadMessages.isNotEmpty,
                          child: CircleAvatar(
                            backgroundColor: parseColor(channel.color),
                            child: Text(channel.name.characters.first.toUpperCase()),
                          ),
                        ),
                        onExpansionChanged: (isExpanded) {
                          if (isExpanded) {
                            context.read<ChannelsCubit>().getChannelTopics(
                              streamId: channel.streamId,
                              unreadMessages: messagesState.unreadMessages,
                            );
                          }
                        },
                        children: [
                          Skeletonizer(
                            enabled: state.pendingTopicsId == channel.streamId,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 400),
                              child: ListView.builder(
                                itemCount: channel.topics.isEmpty ? 3 : channel.topics.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  Widget? trailing;
                                  if (channel.topics.isNotEmpty) {
                                    trailing = channel.topics[index].unreadMessages.isNotEmpty
                                        ? Text("${channel.topics[index].unreadMessages.length}")
                                        : null;
                                  }
                                  return ListTile(
                                    title: Text(
                                      channel.topics.isEmpty
                                          ? 'Loading...'
                                          : channel.topics[index].name,
                                    ),
                                    leading: Icon(Icons.topic),
                                    trailing: trailing,
                                    onTap: state.pendingTopicsId != channel.streamId
                                        ? () async {
                                            context.read<ChannelsCubit>().getChannelMessages(
                                              channel.streamId,
                                            );
                                          }
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
