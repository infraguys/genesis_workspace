part of 'messages_cubit.dart';

class MessagesState {
  final List<MessageEntity> messages;
  const MessagesState({required this.messages});

  List<MessageEntity> get unreadMessages =>
      messages.where((m) => m.hasUnreadMessages).toList(growable: false);

  MessagesState copyWith({List<MessageEntity>? messages}) =>
      MessagesState(messages: messages ?? this.messages);
}
