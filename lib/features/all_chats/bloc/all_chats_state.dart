part of 'all_chats_cubit.dart';

class AllChatsState {
  final DmUserEntity? selectedDmChat;
  final ChannelEntity? selectedChannel;
  final TopicEntity? selectedTopic;

  AllChatsState({this.selectedDmChat, this.selectedChannel, this.selectedTopic});

  AllChatsState copyWith({
    Object? selectedDmChat = _noChange,
    Object? selectedChannel = _noChange,
    Object? selectedTopic = _noChange,
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
    );
  }

  static const Object _noChange = Object();
}
