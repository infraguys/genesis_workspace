part of 'all_chats_cubit.dart';

class AllChatsState {
  DmUserEntity? selectedDmChat;
  ChannelEntity? selectedChannel;
  TopicEntity? selectedTopic;
  Set<int>? selectedGroupChat;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final Map<int, FolderMembers> folderMembersById;
  Set<int>? filterDmUserIds;
  Set<int>? filterChannelIds;
  Set<int>? filterGroupChatIds;

  bool get isEmptyFolder =>
      ((filterChannelIds?.isEmpty ?? false) &&
          (filterDmUserIds?.isEmpty ?? false) &&
          (filterGroupChatIds?.isEmpty ?? false)) &&
      selectedFolderIndex != 0;

  AllChatsState({
    this.selectedDmChat,
    this.selectedChannel,
    this.selectedTopic,
    this.selectedGroupChat,
    required this.folders,
    required this.selectedFolderIndex,
    this.filterDmUserIds,
    this.filterChannelIds,
    this.filterGroupChatIds,
    required this.folderMembersById,
  });

  AllChatsState copyWith({
    DmUserEntity? selectedDmChat,
    ChannelEntity? selectedChannel,
    TopicEntity? selectedTopic,
    Set<int>? selectedGroupChat,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    Set<int>? filterDmUserIds,
    Set<int>? filterChannelIds,
    Set<int>? filterGroupChatIds,
    Map<int, FolderMembers>? folderMembersById,
  }) {
    return AllChatsState(
      selectedDmChat: selectedDmChat ?? this.selectedDmChat,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      filterDmUserIds: filterDmUserIds ?? this.filterDmUserIds,
      filterChannelIds: filterChannelIds ?? this.filterChannelIds,
      filterGroupChatIds: filterGroupChatIds ?? this.filterGroupChatIds,
      folderMembersById: folderMembersById ?? this.folderMembersById,
      selectedGroupChat: selectedGroupChat ?? this.selectedGroupChat,
    );
  }

  static const Object _noChange = Object();
}
