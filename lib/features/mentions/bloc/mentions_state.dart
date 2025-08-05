part of 'mentions_cubit.dart';

class MentionsState {
  List<MessageEntity> messages;
  bool isLoadingMore;
  bool isAllLoaded;

  MentionsState({required this.messages, required this.isLoadingMore, required this.isAllLoaded});

  MentionsState copyWith({List<MessageEntity>? messages, bool? isLoadingMore, bool? isAllLoaded}) {
    return MentionsState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAllLoaded: isAllLoaded ?? this.isAllLoaded,
    );
  }
}
