part of 'create_chat_cubit.dart';

sealed class CreateChatState {}

class CreateChatInitial extends CreateChatState {}

class CreateChatPending extends CreateChatState {}

class CreateChatError extends CreateChatState {
  final String msg;
  CreateChatError({required this.msg});
}

class CreateChatAlreadyExistError extends CreateChatState {}
