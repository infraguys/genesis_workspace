import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/messenger/bloc/chats_list/chats_list_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/messenger_view.dart';

class Messenger extends StatelessWidget {
  const Messenger({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<MessengerCubit>()),
        BlocProvider(create: (context) => getIt<ChatsListCubit>()),
      ],
      child: MessengerView(),
    );
  }
}
