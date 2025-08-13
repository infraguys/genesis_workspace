part of 'messages_cubit.dart';

class MessagesState {
  List<MessageEntity> messages;

  MessagesState({required this.messages});

  MessagesState copyWith({List<MessageEntity>? messages, List<MessageEntity>? unreadMessages}) {
    return MessagesState(messages: messages ?? this.messages);
  }
}
