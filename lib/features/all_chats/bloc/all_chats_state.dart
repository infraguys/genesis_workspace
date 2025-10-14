part of 'all_chats_cubit.dart';

class AllChatsState {
  DmUserEntity? selectedDmChat;
  ChannelEntity? selectedChannel;
  TopicEntity? selectedTopic;
  Set<int>? selectedGroupChat;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  Set<int>? filterDmUserIds;
  Set<int>? filterChannelIds;
  final Map<int, FolderMembers> folderMembersById;

  bool get isEmptyFolder =>
      ((filterChannelIds?.isEmpty ?? false) && (filterDmUserIds?.isEmpty ?? false)) &&
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
      folderMembersById: folderMembersById ?? this.folderMembersById,
      selectedGroupChat: selectedGroupChat ?? this.selectedGroupChat,
    );
  }

  static const Object _noChange = Object();
}
