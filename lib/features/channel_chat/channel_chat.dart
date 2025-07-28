import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/view/channel_chat_view.dart';

class ChannelChat extends StatelessWidget {
  final ChannelEntity channel;
  const ChannelChat({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChannelChatCubit(),
      child: ChannelChatView(channel: channel),
    );
  }
}
