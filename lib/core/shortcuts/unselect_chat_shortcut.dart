import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';

class UnselectChatIntent extends Intent {
  const UnselectChatIntent();
}

class UnselectChatAction extends ContextAction {
  @override
  Object? invoke(Intent intent, [BuildContext? context]) {
    final messengerCubit = context!.read<MessengerCubit>();
    final messengerState = messengerCubit.state;

    if (messengerState.selectedChat != null || messengerState.usersIds.isNotEmpty) {
      messengerCubit.unselectChat();
    }

    return null;
  }
}
