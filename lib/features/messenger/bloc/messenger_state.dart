part of 'messenger_cubit.dart';

class MessengerState {
  final UserEntity? selfUser;
  final List<FolderItemEntity> folders;
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
  });

  MessengerState copyWith({
    UserEntity? selfUser,
    List<FolderItemEntity>? folders,
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
    );
  }
}
