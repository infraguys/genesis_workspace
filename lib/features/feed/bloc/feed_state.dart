part of 'feed_cubit.dart';

class FeedState {
  List<MessageEntity> messages;

  FeedState({required this.messages});

  FeedState copyWith({List<MessageEntity>? messages}) {
    return FeedState(messages: messages ?? this.messages);
  }
}
