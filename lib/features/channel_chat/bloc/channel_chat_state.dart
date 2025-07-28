part of 'channel_chat_cubit.dart';

class ChannelChatState {
  List<MessageEntity> messages;
  bool isMessagePending;
  bool isLoadingMore;
  bool isAllMessagesLoaded;
  int? lastMessageId;
  ChannelEntity? channel;
  TopicEntity? topic;
  int? typingUserId;
  TypingEventOp selfTypingOp;
  Set<int> pendingToMarkAsRead;

  ChannelChatState({
    required this.messages,
    required this.isAllMessagesLoaded,
    required this.isLoadingMore,
    required this.isMessagePending,
    this.lastMessageId,
    this.channel,
    this.typingUserId,
    required this.selfTypingOp,
    this.topic,
    required this.pendingToMarkAsRead,
  });

  ChannelChatState copyWith({
    List<MessageEntity>? messages,
    bool? isAllMessagesLoaded,
    bool? isLoadingMore,
    bool? isMessagePending,
    int? lastMessageId,
    ChannelEntity? channel,
    int? typingUserId,
    TypingEventOp? selfTypingOp,
    TopicEntity? topic,
    Set<int>? pendingToMarkAsRead,
  }) {
    return ChannelChatState(
      messages: messages ?? this.messages,
      isAllMessagesLoaded: isAllMessagesLoaded ?? this.isAllMessagesLoaded,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMessagePending: isMessagePending ?? this.isMessagePending,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      channel: channel ?? this.channel,
      typingUserId: typingUserId ?? this.typingUserId,
      selfTypingOp: selfTypingOp ?? this.selfTypingOp,
      topic: topic ?? this.topic,
      pendingToMarkAsRead: pendingToMarkAsRead ?? this.pendingToMarkAsRead,
    );
  }
}
