part of 'messenger_cubit.dart';

class MessengerState {
  final UserEntity? selfUser;
  final List<FolderEntity> folders;
  final int selectedFolderIndex;
  final List<MessageEntity> messages;
  final List<MessageEntity> unreadMessages;
  final List<ChatEntity> chats;
  final ChatEntity? selectedChat;
  String? selectedTopic;
  final List<PinnedChatEntity> pinnedChats;
  Set<int>? filteredChatIds;
  List<ChatEntity>? filteredChats;
  final bool foundOldestMessage;
  final List<SubscriptionEntity> subscribedChannels;
  final bool isFolderSaving;

  MessengerState({
    this.selfUser,
    required this.folders,
    required this.selectedFolderIndex,
    required this.messages,
    required this.unreadMessages,
    required this.chats,
    this.selectedChat,
    this.selectedTopic,
    required this.pinnedChats,
    this.filteredChatIds,
    this.filteredChats,
    required this.foundOldestMessage,
    required this.subscribedChannels,
    this.isFolderSaving = false,
  });

  MessengerState copyWith({
    UserEntity? selfUser,
    List<FolderEntity>? folders,
    int? selectedFolderIndex,
    List<MessageEntity>? messages,
    List<MessageEntity>? unreadMessages,
    List<ChatEntity>? chats,
    ChatEntity? selectedChat,
    String? selectedTopic,
    List<PinnedChatEntity>? pinnedChats,
    Set<int>? filteredChatIds,
    List<ChatEntity>? filteredChats,
    bool? foundOldestMessage,
    List<SubscriptionEntity>? subscribedChannels,
    bool? isFolderSaving,
  }) {
    return MessengerState(
      selfUser: selfUser ?? this.selfUser,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      chats: chats ?? this.chats,
      selectedChat: selectedChat ?? this.selectedChat,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      filteredChatIds: filteredChatIds ?? this.filteredChatIds,
      filteredChats: filteredChats ?? this.filteredChats,
      foundOldestMessage: foundOldestMessage ?? this.foundOldestMessage,
      subscribedChannels: subscribedChannels ?? this.subscribedChannels,
      isFolderSaving: isFolderSaving ?? this.isFolderSaving,
    );
  }
}
