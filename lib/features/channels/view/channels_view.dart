import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';

class ChannelsView extends StatefulWidget {
  const ChannelsView({super.key});

  @override
  State<ChannelsView> createState() => ChannelsViewState();
}

class ChannelsViewState extends State<ChannelsView> {
  late final Future _future;

  @override
  void initState() {
    _future = context.read<ChannelsCubit>().getChannels();
    super.initState();
  }

  final Set<int> _expandedChannels = {};

  void _toggleTopics(int streamId) {
    setState(() {
      if (_expandedChannels.contains(streamId)) {
        _expandedChannels.remove(streamId);
      } else {
        _expandedChannels.add(streamId);
      }
    });
  }

  List<String> _mockTopics() {
    return ['Топик 1', 'Топик 2', 'Топик 3'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Channels')),
      // floatingActionButton: IconButton(onPressed: () {}, icon: Icon(Icons.add)),
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
              return ListView.builder(
                itemCount: state.channels.length,
                itemBuilder: (context, index) {
                  final channel = state.channels[index];
                  final topics = _mockTopics();

                  return ExpansionTile(
                    title: Text(channel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(channel.description),
                    leading: CircleAvatar(
                      backgroundColor: parseColor(channel.color),
                      child: Text(channel.name.characters.first.toUpperCase()),
                    ),
                    children: topics
                        .map(
                          (topic) => ListTile(
                            title: Text(topic),
                            leading: const Icon(Icons.topic),
                            onTap: () {
                              // Обработай переход к сообщениям топика
                            },
                          ),
                        )
                        .toList(),
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
