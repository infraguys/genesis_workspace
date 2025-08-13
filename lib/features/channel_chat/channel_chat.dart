import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/view/channel_chat_view.dart';

class ChannelChatExtra {
  final ChannelEntity channel;
  final TopicEntity? topicEntity;

  ChannelChatExtra({required this.channel, this.topicEntity});
}

class ChannelChat extends StatelessWidget {
  final ChannelChatExtra extra;
  const ChannelChat({super.key, required this.extra});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChannelChatCubit>(),
      child: ChannelChatView(extra: extra),
    );
  }
}
