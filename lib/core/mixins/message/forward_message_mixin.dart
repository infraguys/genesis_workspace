import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages/messages_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/forward_message/forward_message_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/forward_message_dialog/forward_message_dialog.dart';

mixin ForwardMessageMixin {
  Future<void> onForward(
    BuildContext context, {
    MessageEntity? message,
    String? quote,
    VoidCallback? closeOverlay,
  }) async {
    closeOverlay?.call();

    if (!context.mounted) return;

    final chatCubit = context.read<ChatCubit>();
    final channelChatCubit = context.read<ChannelChatCubit>();
    final messagesCubit = context.read<MessagesCubit>();
    final messengerCubit = context.read<MessengerCubit>();
    final messagesSelectCubit = context.read<MessagesSelectCubit>();

    final selectedMessages = messagesSelectCubit.state.selectedMessages;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: chatCubit),
            BlocProvider.value(value: channelChatCubit),
            BlocProvider.value(value: messagesCubit),
            BlocProvider.value(value: messengerCubit),
            BlocProvider(create: (_) => ForwardMessageCubit()),
          ],
          child: ForwardMessageDialog(
            message: message,
            selectedMessages: selectedMessages,
            quote: quote,
          ),
        );
      },
    );
  }
}
