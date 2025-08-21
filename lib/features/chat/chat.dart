import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/chat/view/chat_view.dart';

class Chat extends StatelessWidget {
  final int? userId;

  const Chat({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    assert(userId != null, 'userId cannot be null');
    return BlocProvider(
      create: (context) => getIt<ChatCubit>(),
      child: ChatView(userId: userId!),
    );
  }
}
