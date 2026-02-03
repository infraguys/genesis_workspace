import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:injectable/injectable.dart';

part 'messages_select_state.dart';

@injectable
class MessagesSelectCubit extends Cubit<MessagesSelectState> {
  MessagesSelectCubit()
    : super(
        MessagesSelectState(
          selectedMessages: [],
          isActive: false,
        ),
      );

  void setSelectMode(bool isActive, {MessageEntity? selectedMessage}) {
    assert(
      !isActive || selectedMessage != null,
      'selectedMessage must not be null when select mode is active',
    );
    if (isActive) {
      emit(state.copyWith(selectedMessages: [selectedMessage!], isActive: true));
    } else {
      emit(state.copyWith(isActive: false));
    }
  }

  void toggleMessageSelection(MessageEntity message) {
    final currentSelectedMessages = state.selectedMessages;

    final updatedSelectedMessages = [...currentSelectedMessages];
    final isMessageSelected = updatedSelectedMessages.any((selected) => selected.id == message.id);

    if (isMessageSelected) {
      updatedSelectedMessages.removeWhere((selected) => selected.id == message.id);
    } else {
      updatedSelectedMessages.add(message);
    }

    emit(state.copyWith(selectedMessages: updatedSelectedMessages, isActive: true));
  }

  void setForwardMessages(List<MessageEntity> messages) {
    emit(state.copyWith(selectedMessages: messages, isActive: false));
  }

  void clearForwardMessages() {
    emit(state.copyWith(selectedMessages: [], isActive: false));
  }
}
