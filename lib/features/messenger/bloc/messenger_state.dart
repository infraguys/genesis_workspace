part of 'messenger_cubit.dart';

class MessengerState {
  final UserEntity? selfUser;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final Map<int, FolderMembers> folderMembersById;
  final List<MessageEntity> messages;
  final List<MessageEntity> unreadMessages;
  final List<ChatEntity> chats;
  final ChatEntity? selectedChat;
  String? selectedTopic;
  final List<PinnedChatEntity> pinnedChats;
  final Set<int> filteredChatIds;

  MessengerState({
    this.selfUser,
    required this.folders,
    required this.selectedFolderIndex,
    required this.folderMembersById,
    required this.messages,
    required this.unreadMessages,
    required this.chats,
    this.selectedChat,
    this.selectedTopic,
    required this.pinnedChats,
    required this.filteredChatIds,
  });

  MessengerState copyWith({
    UserEntity? selfUser,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    Map<int, FolderMembers>? folderMembersById,
    List<MessageEntity>? messages,
    List<MessageEntity>? unreadMessages,
    List<ChatEntity>? chats,
    ChatEntity? selectedChat,
    String? selectedTopic,
    List<PinnedChatEntity>? pinnedChats,
    Set<int>? filteredChatIds,
  }) {
    return MessengerState(
      selfUser: selfUser ?? this.selfUser,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      folderMembersById: folderMembersById ?? this.folderMembersById,
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      chats: chats ?? this.chats,
      selectedChat: selectedChat ?? this.selectedChat,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      filteredChatIds: filteredChatIds ?? this.filteredChatIds,
    );
  }
}
