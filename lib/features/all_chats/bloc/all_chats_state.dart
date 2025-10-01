part of 'all_chats_cubit.dart';

class AllChatsState {
  final DmUserEntity? selectedDmChat;
  final ChannelEntity? selectedChannel;
  final TopicEntity? selectedTopic;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final Set<int>? filterDmUserIds;
  final Set<int>? filterChannelIds;

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
  });

  AllChatsState copyWith({
    Object? selectedDmChat = _noChange,
    Object? selectedChannel = _noChange,
    Object? selectedTopic = _noChange,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    Object? filterDmUserIds,
    Object? filterChannelIds,
  }) {
    return AllChatsState(
      selectedDmChat: identical(selectedDmChat, _noChange)
          ? this.selectedDmChat
          : selectedDmChat as DmUserEntity?,
      selectedChannel: identical(selectedChannel, _noChange)
          ? this.selectedChannel
          : selectedChannel as ChannelEntity?,
      selectedTopic: identical(selectedTopic, _noChange)
          ? this.selectedTopic
          : selectedTopic as TopicEntity?,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      filterDmUserIds: identical(filterDmUserIds, _noChange)
          ? this.filterDmUserIds
          : filterDmUserIds as Set<int>?,
      filterChannelIds: identical(filterChannelIds, _noChange)
          ? this.filterChannelIds
          : filterChannelIds as Set<int>?,
    );
  }

  static const Object _noChange = Object();
}
