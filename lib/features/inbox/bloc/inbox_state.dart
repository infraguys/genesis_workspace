part of 'inbox_cubit.dart';

class InboxState {
  Map<String, Map<String, List<MessageEntity>>> channelMessages;
  Map<String, List<MessageEntity>> dmMessages;

  InboxState({required this.dmMessages, required this.channelMessages});

  InboxState copyWith({
    Map<String, Map<String, List<MessageEntity>>>? channelMessages,
    Map<String, List<MessageEntity>>? dmMessages,
  }) {
    return InboxState(
      dmMessages: dmMessages ?? this.dmMessages,
      channelMessages: channelMessages ?? this.channelMessages,
    );
  }
}
