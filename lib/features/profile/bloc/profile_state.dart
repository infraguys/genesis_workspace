part of 'profile_cubit.dart';

class ProfileState {
  UserEntity? user;
  int lastPresenceUpdateId;

  ProfileState({required this.user, required this.lastPresenceUpdateId});

  ProfileState copyWith({UserEntity? user, int? lastPresenceUpdateId}) {
    return ProfileState(
      user: user ?? this.user,
      lastPresenceUpdateId: lastPresenceUpdateId ?? this.lastPresenceUpdateId,
    );
  }
}
