import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/messenger_view.dart';

class Messenger extends StatelessWidget {
  const Messenger({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<MessengerCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChannelChatCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChatCubit>(),
        ),
      ],
      child: MessengerView(),
    );
  }
}
