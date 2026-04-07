part of 'channel_members_info_cubit.dart';

sealed class ChannelMembersInfoState {}

final class _Initial extends ChannelMembersInfoState {}

final class ChannelMembersInfoLoadingState extends ChannelMembersInfoState {}

final class ChannelMembersLoadedState extends ChannelMembersInfoState {
  final List<DmUserEntity> users;
  final List<DmUserEntity> channelUsers;

  ChannelMembersLoadedState({required this.users, required this.channelUsers});
}

final class ChannelMembersFailureState extends ChannelMembersInfoState {}
