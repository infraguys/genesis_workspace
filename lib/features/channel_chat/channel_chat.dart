import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/view/channel_chat_view.dart';

class ChannelChat extends StatelessWidget {
  final int channelId;
  final String? topicName;
  const ChannelChat({super.key, required this.channelId, this.topicName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChannelChatCubit>(),
      child: ChannelChatView(channelId: channelId, topicName: topicName),
    );
  }
}
