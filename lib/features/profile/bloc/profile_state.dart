part of 'profile_cubit.dart';

class ProfileState {
  UserEntity? user;
  int lastPresenceUpdateId;
  PresenceStatus myPresence;

  ProfileState({required this.user, required this.lastPresenceUpdateId, required this.myPresence});

  ProfileState copyWith({UserEntity? user, int? lastPresenceUpdateId, PresenceStatus? myPresence}) {
    return ProfileState(
      user: user ?? this.user,
      lastPresenceUpdateId: lastPresenceUpdateId ?? this.lastPresenceUpdateId,
      myPresence: myPresence ?? this.myPresence,
    );
  }
}
