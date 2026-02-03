part of 'messages_select_cubit.dart';

class MessagesSelectState {
  const MessagesSelectState({required this.selectedMessages, required this.isActive});
  final List<MessageEntity> selectedMessages;
  final bool isActive;

  MessagesSelectState copyWith({List<MessageEntity>? selectedMessages, bool? isActive}) {
    return MessagesSelectState(
      selectedMessages: selectedMessages ?? this.selectedMessages,
      isActive: isActive ?? this.isActive,
    );
  }
}
