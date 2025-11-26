part of 'channel_members_info_cubit.dart';

sealed class ChannelMembersInfoState {}

final class _Initial extends ChannelMembersInfoState {}

final class ChannelMembersInfoLoadingState extends ChannelMembersInfoState {}

final class ChannelMembersLoadedState extends ChannelMembersInfoState {
  final List<UserEntity> users;

  ChannelMembersLoadedState(this.users);
}

final class ChannelMembersFailureState extends ChannelMembersInfoState {}
