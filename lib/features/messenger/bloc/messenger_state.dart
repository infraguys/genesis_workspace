part of 'messenger_cubit.dart';

enum OpenedSection {
  chat,
  starredMessages,
  mentions,
}

class MessengerState {
  static const Object _notSpecified = Object();

  final UserEntity? selfUser;
  final List<FolderEntity> folders;
  final int selectedFolderIndex;
  final List<MessageEntity> messages;
  final List<MessageEntity> unreadMessages;
  final List<ChatEntity> chats;
  final ChatEntity? selectedChat;
  final String? selectedTopic;
  final List<PinnedChatEntity> pinnedChats;
  final Set<int>? filteredChatIds;
  final List<ChatEntity>? filteredChats;
  final bool foundOldestMessage;
  final List<SubscriptionEntity> subscribedChannels;
  final bool isFolderSaving;
  final bool isFolderDeleting;
  final Set<int> usersIds;
  final OpenedSection openedSection;

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
    this.isFolderDeleting = false,
    Set<int>? usersIds,
    required this.openedSection,
  }) : usersIds = usersIds ?? {};

  static MessengerState initial = MessengerState(
    selfUser: null,
    folders: [],
    selectedFolderIndex: 0,
    messages: [],
    unreadMessages: [],
    chats: [],
    selectedChat: null,
    pinnedChats: [],
    filteredChatIds: null,
    filteredChats: null,
    foundOldestMessage: false,
    subscribedChannels: [],
    isFolderSaving: false,
    isFolderDeleting: false,
    openedSection: .chat,
  );

  MessengerState copyWith({
    UserEntity? selfUser,
    List<FolderEntity>? folders,
    int? selectedFolderIndex,
    List<MessageEntity>? messages,
    List<MessageEntity>? unreadMessages,
    List<ChatEntity>? chats,
    Object? selectedChat = _notSpecified,
    Object? selectedTopic = _notSpecified,
    List<PinnedChatEntity>? pinnedChats,
    Object? filteredChatIds = _notSpecified,
    Object? filteredChats = _notSpecified,
    bool? foundOldestMessage,
    List<SubscriptionEntity>? subscribedChannels,
    bool? isFolderSaving,
    bool? isFolderDeleting,
    Set<int>? usersIds,
    OpenedSection? openedSection,
  }) {
    return MessengerState(
      selfUser: selfUser ?? this.selfUser,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      chats: chats ?? this.chats,
      selectedChat: identical(selectedChat, _notSpecified) ? this.selectedChat : selectedChat as ChatEntity?,
      selectedTopic: identical(selectedTopic, _notSpecified) ? this.selectedTopic : selectedTopic as String?,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      filteredChatIds: identical(filteredChatIds, _notSpecified) ? this.filteredChatIds : filteredChatIds as Set<int>?,
      filteredChats: identical(filteredChats, _notSpecified) ? this.filteredChats : filteredChats as List<ChatEntity>?,
      foundOldestMessage: foundOldestMessage ?? this.foundOldestMessage,
      subscribedChannels: subscribedChannels ?? this.subscribedChannels,
      isFolderSaving: isFolderSaving ?? this.isFolderSaving,
      isFolderDeleting: isFolderDeleting ?? this.isFolderDeleting,
      usersIds: usersIds ?? this.usersIds,
      openedSection: openedSection ?? this.openedSection,
    );
  }
}
