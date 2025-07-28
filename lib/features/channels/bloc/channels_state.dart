part of 'channels_cubit.dart';

class ChannelsState {
  List<ChannelEntity> channels;
  int? pendingTopicsId;
  int? selectedChannelId;

  ChannelsState({required this.channels, this.pendingTopicsId, this.selectedChannelId});

  ChannelsState copyWith({
    List<ChannelEntity>? channels,
    int? pendingTopicsId,
    int? selectedChannelId,
  }) {
    return ChannelsState(
      channels: channels ?? this.channels,
      pendingTopicsId: pendingTopicsId ?? this.pendingTopicsId,
      selectedChannelId: selectedChannelId ?? this.selectedChannelId,
    );
  }
}
