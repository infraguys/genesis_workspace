part of 'forward_message_cubit.dart';

sealed class ForwardMessageState {}

final class ForwardMessageInitial extends ForwardMessageState {}

final class ForwardMessageSuccess extends ForwardMessageState {
  ForwardMessageSuccess(this.chats);

  final List<ChatEntity> chats;
}
