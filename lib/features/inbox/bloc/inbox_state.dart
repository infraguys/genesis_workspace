part of 'inbox_cubit.dart';

class InboxState {
  // List<MessageEntity> dmMessages;
  List<MessageEntity> channelMessages;
  Map<String, List<MessageEntity>> dmMessages;

  InboxState({
    required this.dmMessages,
    required this.channelMessages,
    // required this.dmMessagesCount,
  });

  InboxState copyWith({
    // List<MessageEntity>? dmMessages,
    List<MessageEntity>? channelMessages,
    Map<String, List<MessageEntity>>? dmMessages,
  }) {
    return InboxState(
      dmMessages: dmMessages ?? this.dmMessages,
      channelMessages: channelMessages ?? this.channelMessages,
      // dmMessagesCount: dmMessagesCount ?? this.dmMessagesCount,
    );
  }
}
