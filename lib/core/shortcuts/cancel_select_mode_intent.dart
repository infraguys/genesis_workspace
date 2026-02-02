import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';

class CancelSelectModeIntent extends Intent {
  const CancelSelectModeIntent();
}

class CancelSelectModeAction extends ContextAction {
  @override
  Object? invoke(Intent intent, [BuildContext? context]) {
    final messagesSelectCubit = context!.read<MessagesSelectCubit>();

    messagesSelectCubit.setSelectMode(false);

    return null;
  }
}
