import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/chat/view/chat_view.dart';

class Chat extends StatelessWidget {
  final DmUserEntity? user;

  const Chat({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    assert(user != null, 'userEntity cannot be null');
    return BlocProvider(
      create: (context) => getIt<ChatCubit>(),
      child: ChatView(userEntity: user!),
    );
  }
}
