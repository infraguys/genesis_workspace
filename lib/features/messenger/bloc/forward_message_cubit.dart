import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';

part 'forward_message_state.dart';

class ForwardMessageCubit extends Cubit<ForwardMessageState> {
  ForwardMessageCubit() : super(ForwardMessageInitial());

  void applyChatFilter(List<ChatEntity> chats, {String query = ''}) {
    final filteredChats = chats.where((chat) {
      final chatTitle = (chat.displayTitle).toLowerCase();

      if (chatTitle.contains(query)) {
        return true;
      }

      return false;
    }).toList();
    emit(ForwardMessageSuccess(filteredChats));
  }
}
