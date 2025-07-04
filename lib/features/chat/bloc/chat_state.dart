part of 'chat_cubit.dart';

class ChatState {
  List<MessageEntity> messages;
  int? chatId;
  int? typingId;
  int? myUserId;
  bool isMessagePending;
  TypingEventOp selfTypingOp;

  ChatState({
    required this.messages,
    this.chatId,
    this.typingId,
    this.myUserId,
    required this.isMessagePending,
    required this.selfTypingOp,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    int? chatId,
    int? typingId,
    int? myUserId,
    bool? isMessagePending,
    TypingEventOp? selfTypingOp,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      typingId: typingId ?? this.typingId,
      myUserId: myUserId ?? this.myUserId,
      isMessagePending: isMessagePending ?? this.isMessagePending,
      selfTypingOp: selfTypingOp ?? this.selfTypingOp,
    );
  }
}
