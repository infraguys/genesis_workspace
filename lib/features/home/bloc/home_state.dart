part of 'home_cubit.dart';

class HomeState {
  bool isUsersPending;
  List<UserEntity> users;
  List<int> typingUsers;

  HomeState({required this.users, required this.isUsersPending, required this.typingUsers});

  HomeState copyWith({List<UserEntity>? users, bool? isUsersPending, List<int>? typingUsers}) {
    return HomeState(
      users: users ?? this.users,
      isUsersPending: isUsersPending ?? this.isUsersPending,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}
