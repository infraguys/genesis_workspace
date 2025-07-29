part of 'channels_cubit.dart';

class ChannelsState {
  List<ChannelEntity> channels;
  List<MessageEntity> unreadMessages;
  int? pendingTopicsId;
  int? selectedChannelId;
  TopicEntity? selectedTopic;
  UserEntity? selfUser;
  ChannelEntity? selectedChannel;

  ChannelsState({
    required this.channels,
    this.pendingTopicsId,
    this.selectedChannelId,
    this.selectedTopic,
    required this.unreadMessages,
    this.selfUser,
    this.selectedChannel,
  });

  ChannelsState copyWith({
    List<ChannelEntity>? channels,
    int? pendingTopicsId,
    int? selectedChannelId,
    TopicEntity? selectedTopic,
    List<MessageEntity>? unreadMessages,
    UserEntity? selfUser,
    ChannelEntity? selectedChannel,
  }) {
    return ChannelsState(
      channels: channels ?? this.channels,
      pendingTopicsId: pendingTopicsId ?? this.pendingTopicsId,
      selectedChannelId: selectedChannelId ?? this.selectedChannelId,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      selfUser: selfUser ?? this.selfUser,
      selectedChannel: selectedChannel ?? this.selectedChannel,
    );
  }
}
