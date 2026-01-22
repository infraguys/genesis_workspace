import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/chat/view/chat_view.dart';

class Chat extends StatelessWidget {
  final int? chatId;
  final List<int> userIds;
  final int? unreadMessagesCount;
  final VoidCallback? leadingOnPressed;

  const Chat({
    super.key,
    this.chatId = -1,
    required this.userIds,
    this.unreadMessagesCount = 0,
    this.leadingOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    final existing = context.maybeRead<ChatCubit>();

    return Builder(
      builder: (context) {
        final chat = ChatView(
          chatId: chatId,
          userIds: userIds,
          unreadMessagesCount: unreadMessagesCount,
          leadingOnPressed: leadingOnPressed,
        );

        if (existing != null) {
          return chat;
        }
        return BlocProvider(
          create: (context) => getIt<ChatCubit>(),
          child: chat,
        );
      },
    );
  }
}
