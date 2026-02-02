part of 'messages_select_cubit.dart';

sealed class MessagesSelectState {}

class MessagesSelectStateDisabled extends MessagesSelectState {}

class MessagesSelectStateActive extends MessagesSelectState {
  final List<MessageEntity> messages;

  MessagesSelectStateActive({required this.messages});
}
