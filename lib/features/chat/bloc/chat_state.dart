part of 'chat_cubit.dart';

class ChatState {
  List<MessageEntity> messages;
  int? chatId;
  int? typingId;
  int? myUserId;
  int? lastMessageId;
  bool isMessagePending;
  bool isLoadingMore;
  bool isAllMessagesLoaded;
  TypingEventOp selfTypingOp;
  Set<int> pendingToMarkAsRead;

  ChatState({
    required this.messages,
    this.chatId,
    this.typingId,
    this.myUserId,
    this.lastMessageId,
    required this.isMessagePending,
    required this.isLoadingMore,
    required this.isAllMessagesLoaded,
    required this.selfTypingOp,
    required this.pendingToMarkAsRead,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    int? chatId,
    int? typingId,
    int? myUserId,
    int? lastMessageId,
    bool? isMessagePending,
    bool? isLoadingMore,
    bool? isAllMessagesLoaded,
    TypingEventOp? selfTypingOp,
    Set<int>? pendingToMarkAsRead,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      typingId: typingId ?? this.typingId,
      myUserId: myUserId ?? this.myUserId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      isMessagePending: isMessagePending ?? this.isMessagePending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAllMessagesLoaded: isAllMessagesLoaded ?? this.isAllMessagesLoaded,
      selfTypingOp: selfTypingOp ?? this.selfTypingOp,
      pendingToMarkAsRead: pendingToMarkAsRead ?? this.pendingToMarkAsRead,
    );
  }
}
