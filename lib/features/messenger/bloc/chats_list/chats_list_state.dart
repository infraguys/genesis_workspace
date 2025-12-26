part of 'chats_list_cubit.dart';

class ChatsListState {
  static const Object _notSpecified = Object();

  final UserEntity? selfUser;
  final List<ChatEntity> chats;
  final bool isLoadingMessages;
  final bool isLoadingMoreMessages;
  final bool hasLoadingChatsError;

  ChatsListState({
    required this.chats,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.hasLoadingChatsError,
    this.selfUser,
  });

  ChatsListState copyWith({
    Object? selfUser = _notSpecified,
    List<ChatEntity>? chats,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    bool? hasLoadingChatsError,
  }) {
    return ChatsListState(
      selfUser: identical(selfUser, _notSpecified) ? this.selfUser : selfUser as UserEntity?,
      chats: chats ?? this.chats,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      hasLoadingChatsError: hasLoadingChatsError ?? this.hasLoadingChatsError,
    );
  }
}
