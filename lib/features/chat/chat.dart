import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/chat/view/chat_view.dart';

class Chat extends StatelessWidget {
  final List<int> userIds;
  final int? unreadMessagesCount;

  const Chat({super.key, required this.userIds, this.unreadMessagesCount = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatCubit>(),
      child: ChatView(userIds: userIds, unreadMessagesCount: unreadMessagesCount),
    );
  }
}
