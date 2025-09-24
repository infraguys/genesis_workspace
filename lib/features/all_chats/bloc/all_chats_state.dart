part of 'all_chats_cubit.dart';

class AllChatsState {
  final DmUserEntity? selectedDmChat;
  final ChannelEntity? selectedChannel;
  final TopicEntity? selectedTopic;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;

  AllChatsState({
    this.selectedDmChat,
    this.selectedChannel,
    this.selectedTopic,
    required this.folders,
    required this.selectedFolderIndex,
  });

  AllChatsState copyWith({
    Object? selectedDmChat = _noChange,
    Object? selectedChannel = _noChange,
    Object? selectedTopic = _noChange,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
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
    );
  }

  static const Object _noChange = Object();
}
