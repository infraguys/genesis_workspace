part of 'starred_cubit.dart';

class StarredState {
  final List<MessageEntity> messages;
  final int? lastMessageId;
  final bool isLoadingMore;
  final bool isAllLoaded;

  const StarredState({
    required this.messages,
    required this.isLoadingMore,
    required this.isAllLoaded,
    this.lastMessageId,
  });

  StarredState copyWith({
    List<MessageEntity>? messages,
    bool? isLoadingMore,
    bool? isAllLoaded,
    int? lastMessageId,
  }) {
    return StarredState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAllLoaded: isAllLoaded ?? this.isAllLoaded,
      lastMessageId: lastMessageId ?? this.lastMessageId,
    );
  }
}
