import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelChatView extends StatefulWidget {
  final ChannelEntity channel;
  const ChannelChatView({super.key, required this.channel});

  @override
  State<ChannelChatView> createState() => _ChannelChatViewState();
}

class _ChannelChatViewState extends State<ChannelChatView> {
  late final Future _future;

  @override
  void didChangeDependencies() {
    _future = context.read<ChannelChatCubit>().getChannelMessages(widget.channel.name);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.name)),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Some error..."));
            }
          }
          return Skeletonizer(
            enabled: snapshot.connectionState == ConnectionState.waiting,
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Item number $index as title'),
                    subtitle: const Text('Subtitle here'),
                    trailing: const Icon(Icons.ac_unit),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
