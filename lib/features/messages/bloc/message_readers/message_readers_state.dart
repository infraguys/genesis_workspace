part of 'message_readers_cubit.dart';

sealed class MessageReadersState {}

final class _MessageReadersInitialState extends MessageReadersState {}

final class MessageReadersLoadingState extends MessageReadersState {}

final class MessageReadersSuccessState extends MessageReadersState {
  MessageReadersSuccessState(this.users);

  final List<UserEntity> users;
}

final class MessageReadersFailureState extends MessageReadersState {
  final String message;

  MessageReadersFailureState(this.message);
}
