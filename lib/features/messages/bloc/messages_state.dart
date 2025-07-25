part of 'messages_cubit.dart';

class MessagesState {
  List<MessageEntity> messages;
  List<MessageEntity> unreadMessages;

  MessagesState({required this.messages, required this.unreadMessages});

  MessagesState copyWith({List<MessageEntity>? messages, List<MessageEntity>? unreadMessages}) {
    return MessagesState(
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }
}
