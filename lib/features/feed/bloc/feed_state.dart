part of 'feed_cubit.dart';

class FeedState {
  List<MessageEntity> messages;
  bool isLoadingMore;
  bool isAllMessagesLoaded;
  int? lastMessageId;

  FeedState({
    required this.messages,
    required this.isLoadingMore,
    required this.isAllMessagesLoaded,
    this.lastMessageId,
  });

  FeedState copyWith({
    List<MessageEntity>? messages,
    bool? isLoadingMore,
    bool? isAllMessagesLoaded,
    int? lastMessageId,
  }) {
    return FeedState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAllMessagesLoaded: isAllMessagesLoaded ?? this.isAllMessagesLoaded,
      lastMessageId: lastMessageId ?? this.lastMessageId,
    );
  }
}
