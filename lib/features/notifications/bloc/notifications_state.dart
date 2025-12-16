part of 'notifications_cubit.dart';

class NotificationsState {
  final UserEntity? user;
  final Set<int> mutedChatsIds;
  NotificationsState({
    this.user,
    required this.mutedChatsIds,
  });

  NotificationsState copyWith({
    UserEntity? user,
    Set<int>? mutedChatsIds,
  }) {
    return NotificationsState(
      user: user ?? this.user,
      mutedChatsIds: mutedChatsIds ?? this.mutedChatsIds,
    );
  }
}
