part of 'channels_cubit.dart';

class ChannelsState {
  List<ChannelEntity> channels;
  int? pendingTopicsId;

  ChannelsState({required this.channels, this.pendingTopicsId});

  ChannelsState copyWith({List<ChannelEntity>? channels, int? pendingTopicsId}) {
    return ChannelsState(
      channels: channels ?? this.channels,
      pendingTopicsId: pendingTopicsId ?? this.pendingTopicsId,
    );
  }
}
