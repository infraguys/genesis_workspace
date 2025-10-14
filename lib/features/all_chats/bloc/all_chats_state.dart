part of 'all_chats_cubit.dart';

class AllChatsState {
  DmUserEntity? selectedDmChat;
  ChannelEntity? selectedChannel;
  TopicEntity? selectedTopic;
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
    required this.folders,
    required this.selectedFolderIndex,
    this.filterDmUserIds,
    this.filterChannelIds,
    required this.folderMembersById,
  });

  AllChatsState copyWith({
    // Object? selectedDmChat = _noChange,
    // Object? selectedChannel = _noChange,
    // Object? selectedTopic = _noChange,
    DmUserEntity? selectedDmChat,
    ChannelEntity? selectedChannel,
    TopicEntity? selectedTopic,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    // Object? filterDmUserIds,
    // Object? filterChannelIds,
    Set<int>? filterDmUserIds,
    Set<int>? filterChannelIds,
    Map<int, FolderMembers>? folderMembersById,
  }) {
    return AllChatsState(
      // selectedDmChat: identical(selectedDmChat, _noChange)
      //     ? this.selectedDmChat
      //     : selectedDmChat as DmUserEntity?,
      // selectedChannel: identical(selectedChannel, _noChange)
      //     ? this.selectedChannel
      //     : selectedChannel as ChannelEntity?,
      // selectedTopic: identical(selectedTopic, _noChange)
      //     ? this.selectedTopic
      //     : selectedTopic as TopicEntity?,
      selectedDmChat: selectedDmChat ?? this.selectedDmChat,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      // filterDmUserIds: identical(filterDmUserIds, _noChange)
      //     ? this.filterDmUserIds
      //     : filterDmUserIds as Set<int>?,
      // filterChannelIds: identical(filterChannelIds, _noChange)
      //     ? this.filterChannelIds
      //     : filterChannelIds as Set<int>?,
      filterDmUserIds: filterDmUserIds ?? this.filterDmUserIds,
      filterChannelIds: filterChannelIds ?? this.filterChannelIds,
      folderMembersById: folderMembersById ?? this.folderMembersById,
    );
  }

  static const Object _noChange = Object();
}
