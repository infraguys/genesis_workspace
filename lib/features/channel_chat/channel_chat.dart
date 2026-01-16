import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/view/channel_chat_view.dart';

class ChannelChat extends StatelessWidget {
  const ChannelChat({
    super.key,
    required this.chatId,
    required this.channelId,
    this.topicName,
    this.unreadMessagesCount = 0,
    this.leadingOnPressed,
  });

  final int chatId;
  final int channelId;
  final String? topicName;
  final int? unreadMessagesCount;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final existing = context.maybeRead<ChannelChatCubit>();

    return Builder(
      builder: (context) {
        final channel = ChannelChatView(
          chatId: chatId,
          channelId: channelId,
          topicName: topicName,
          unreadMessagesCount: unreadMessagesCount,
          leadingOnPressed: leadingOnPressed,
        );

        if (existing != null) {
          return channel;
        }
        return BlocProvider(
          create: (context) => getIt<ChannelChatCubit>(),
          child: channel,
        );
      },
    );
  }
}
