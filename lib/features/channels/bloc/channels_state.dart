part of 'channels_cubit.dart';

class ChannelsState {
  List<ChannelEntity> channels;
  int? pendingTopicsId;
  int? selectedChannelId;
  TopicEntity? selectedTopic;

  ChannelsState({
    required this.channels,
    this.pendingTopicsId,
    this.selectedChannelId,
    this.selectedTopic,
  });

  ChannelsState copyWith({
    List<ChannelEntity>? channels,
    int? pendingTopicsId,
    int? selectedChannelId,
    TopicEntity? selectedTopic,
  }) {
    return ChannelsState(
      channels: channels ?? this.channels,
      pendingTopicsId: pendingTopicsId ?? this.pendingTopicsId,
      selectedChannelId: selectedChannelId ?? this.selectedChannelId,
      selectedTopic: selectedTopic ?? this.selectedTopic,
    );
  }
}
