import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:injectable/injectable.dart';

part 'messages_select_state.dart';

@injectable
class MessagesSelectCubit extends Cubit<MessagesSelectState> {
  MessagesSelectCubit() : super(MessagesSelectStateDisabled());

  void setSelectMode(bool isActive, {MessageEntity? selectedMessage}) {
    if (isActive) {
      emit(MessagesSelectStateActive(messages: [selectedMessage!]));
    } else {
      emit(MessagesSelectStateDisabled());
    }
  }
}
