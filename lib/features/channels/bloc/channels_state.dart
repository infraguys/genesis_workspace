part of 'channels_cubit.dart';

class ChannelsState {
  List<SubscriptionEntity> channels;

  ChannelsState({required this.channels});

  ChannelsState copyWith({List<SubscriptionEntity>? channels}) {
    return ChannelsState(channels: channels ?? this.channels);
  }
}
