part of 'reactions_cubit.dart';

class ReactionsState {
  final List<MessageEntity> messages;
  final int? lastMessageId;
  final bool isLoadingMore;
  final bool isAllLoaded;

  const ReactionsState({
    required this.messages,
    required this.isLoadingMore,
    required this.isAllLoaded,
    this.lastMessageId,
  });

  ReactionsState copyWith({
    List<MessageEntity>? messages,
    bool? isLoadingMore,
    bool? isAllLoaded,
    int? lastMessageId,
  }) {
    return ReactionsState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAllLoaded: isAllLoaded ?? this.isAllLoaded,
      lastMessageId: lastMessageId ?? this.lastMessageId,
    );
  }
}
