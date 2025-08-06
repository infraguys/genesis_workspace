part of 'inbox_cubit.dart';

class InboxState {
  Map<String, Map<String, List<MessageEntity>>> channelMessages;
  Map<String, List<MessageEntity>> dmMessages;
  int? pendingId;

  InboxState({required this.dmMessages, required this.channelMessages, this.pendingId});

  InboxState copyWith({
    Map<String, Map<String, List<MessageEntity>>>? channelMessages,
    Map<String, List<MessageEntity>>? dmMessages,
    int? pendingId,
  }) {
    return InboxState(
      dmMessages: dmMessages ?? this.dmMessages,
      channelMessages: channelMessages ?? this.channelMessages,
      pendingId: pendingId ?? this.pendingId,
    );
  }
}
