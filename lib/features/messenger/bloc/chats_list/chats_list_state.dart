part of 'chats_list_cubit.dart';

class ChatsListState {
  static const Object _notSpecified = Object();

  final UserEntity? selfUser;
  final List<ChatEntity> chats;
  final List<ChatEntity> filteredChats;
  final bool isLoadingMessages;
  final bool isLoadingMoreMessages;
  final bool hasLoadingChatsError;
  final Set<int>? filteredChatIds;

  ChatsListState({
    required this.chats,
    required this.filteredChats,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.hasLoadingChatsError,
    this.selfUser,
    this.filteredChatIds,
  });

  ChatsListState copyWith({
    Object? selfUser = _notSpecified,
    List<ChatEntity>? chats,
    List<ChatEntity>? filteredChats,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    bool? hasLoadingChatsError,
    Object? filteredChatIds = _notSpecified,
  }) {
    return ChatsListState(
      selfUser: identical(selfUser, _notSpecified) ? this.selfUser : selfUser as UserEntity?,
      chats: chats ?? this.chats,
      filteredChats: filteredChats ?? this.filteredChats,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      hasLoadingChatsError: hasLoadingChatsError ?? this.hasLoadingChatsError,
      filteredChatIds: identical(filteredChatIds, _notSpecified) ? this.filteredChatIds : filteredChatIds as Set<int>?,
    );
  }
}
