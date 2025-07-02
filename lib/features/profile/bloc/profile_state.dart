part of 'profile_cubit.dart';

class ProfileState {
  UserEntity? user;

  ProfileState({required this.user});

  ProfileState copyWith({UserEntity? user}) {
    return ProfileState(user: user ?? this.user);
  }
}
