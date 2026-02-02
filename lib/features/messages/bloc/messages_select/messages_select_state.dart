part of 'messages_select_cubit.dart';

sealed class MessagesSelectState {
  const MessagesSelectState();

  List<MessageEntity> get selectedMessages => switch (this) {
    MessagesSelectStateActive(:final messages) => messages,
    MessagesSelectStateDisabled() => const <MessageEntity>[],
  };

  bool get isActive => this is MessagesSelectStateActive;
}

class MessagesSelectStateDisabled extends MessagesSelectState {}

class MessagesSelectStateActive extends MessagesSelectState {
  final List<MessageEntity> messages;

  MessagesSelectStateActive({required this.messages});
}
