part of 'all_chats_cubit.dart';

class AllChatsState {
  DmUserEntity? selectedDmChat;
  ChannelEntity? selectedChannel;
  TopicEntity? selectedTopic;
  Set<int>? selectedGroupChat;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final Map<int, FolderMembers> folderMembersById;
  Set<int>? filterChatIds;
  final bool isInitialDataPending;

  bool get isEmptyFolder => (filterChatIds?.isEmpty ?? false) && selectedFolderIndex != 0;

  AllChatsState({
    this.selectedDmChat,
    this.selectedChannel,
    this.selectedTopic,
    this.selectedGroupChat,
    required this.folders,
    required this.selectedFolderIndex,
    this.filterChatIds,
    required this.folderMembersById,
    required this.isInitialDataPending,
  });

  AllChatsState copyWith({
    DmUserEntity? selectedDmChat,
    ChannelEntity? selectedChannel,
    TopicEntity? selectedTopic,
    Set<int>? selectedGroupChat,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    Set<int>? filterChatIds,
    Map<int, FolderMembers>? folderMembersById,
    bool? isInitialDataPending,
  }) {
    return AllChatsState(
      selectedDmChat: selectedDmChat ?? this.selectedDmChat,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      filterChatIds: filterChatIds ?? this.filterChatIds,
      folderMembersById: folderMembersById ?? this.folderMembersById,
      selectedGroupChat: selectedGroupChat ?? this.selectedGroupChat,
      isInitialDataPending: isInitialDataPending ?? this.isInitialDataPending,
    );
  }

  static const Object _noChange = Object();
}
