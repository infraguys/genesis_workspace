part of 'chat_cubit.dart';

class ChatState {
  List<MessageEntity> messages;

  ChatState({required this.messages});

  ChatState copyWith({List<MessageEntity>? messages}) {
    return ChatState(messages: messages ?? this.messages);
  }
}
