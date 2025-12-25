import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/users_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_all_presences_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:injectable/injectable.dart';

part 'channel_members_info_state.dart';

@injectable
class ChannelMembersInfoCubit extends Cubit<ChannelMembersInfoState> {
  ChannelMembersInfoCubit({
    required GetUsersUseCase getUsersUseCase,
    required GetAllPresencesUseCase getAllPresenceUseCase,
  }) : _getUsersUseCase = getUsersUseCase,
       _getAllPresencesUseCase = getAllPresenceUseCase,
       super(_Initial());

  final GetUsersUseCase _getUsersUseCase;
  final GetAllPresencesUseCase _getAllPresencesUseCase;

  Future<void> getUsers(Set<int> ids) async {
    emit(ChannelMembersInfoLoadingState());
    try {
      final users = await _getUsersUseCase(UsersRequestEntity(userIds: ids.toList()));
      final response = await _getAllPresencesUseCase();
      final dmUsers = users.map((user) {
        if (response.presences.containsKey(user.email)) {
          final presence = response.presences[user.email]!;
          final dmUser = user.toDmUser();
          return dmUser.copyWith(
            presenceStatus: presence.aggregated!.status,
            presenceTimestamp: presence.aggregated!.timestamp,
          );
        }
        return user.toDmUser();
      });
      emit(ChannelMembersLoadedState(dmUsers.toList()));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }
}
