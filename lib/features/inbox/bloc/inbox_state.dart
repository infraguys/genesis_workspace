part of 'inbox_cubit.dart';

class InboxState {
  List<MessageEntity> dmMessages;
  List<MessageEntity> channelMessages;

  InboxState({required this.dmMessages, required this.channelMessages});

  InboxState copyWith({List<MessageEntity>? dmMessages, List<MessageEntity>? channelMessages}) {
    return InboxState(
      dmMessages: dmMessages ?? this.dmMessages,
      channelMessages: channelMessages ?? this.channelMessages,
    );
  }
}
