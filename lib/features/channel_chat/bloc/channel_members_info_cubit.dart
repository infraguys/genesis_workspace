import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/add_subscribers_to_channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';
import 'package:genesis_workspace/domain/users/entities/users_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/add_subscribers_to_channel_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_all_presences_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:injectable/injectable.dart';

part 'channel_members_info_state.dart';

@injectable
class ChannelMembersInfoCubit extends Cubit<ChannelMembersInfoState> {
  ChannelMembersInfoCubit({
    required GetUsersUseCase getUsersUseCase,
    required GetAllPresencesUseCase getAllPresenceUseCase,
    required AddSubscribersToChannelUseCase addSubscribersToChannelUseCase,
  }) : _getUsersUseCase = getUsersUseCase,
       _getAllPresencesUseCase = getAllPresenceUseCase,
       _addSubscribersToChannelUseCase = addSubscribersToChannelUseCase,
       super(_Initial());

  final GetUsersUseCase _getUsersUseCase;
  final GetAllPresencesUseCase _getAllPresencesUseCase;
  final AddSubscribersToChannelUseCase _addSubscribersToChannelUseCase;

  Future<void> getUsers(Set<int> ids) async {
    emit(ChannelMembersInfoLoadingState());
    if (ids.isEmpty) {
      emit(ChannelMembersLoadedState(users: const [], channelUsers: const []));
      return;
    }

    try {
      final users = await _getUsersUseCase(
        UsersRequestEntity(userIds: ids.toList(growable: false)),
      );
      final response = await _getAllPresencesUseCase();
      final dmUsers = _mapUsersWithPresence(users: users, presences: response);
      emit(ChannelMembersLoadedState(users: dmUsers, channelUsers: dmUsers));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<List<DmUserEntity>> getAllUsersForDialog() async {
    final users = await _getUsersUseCase(UsersRequestEntity());
    final response = await _getAllPresencesUseCase();
    return _mapUsersWithPresence(users: users, presences: response);
  }

  Future<void> addSubscribersToChannel({
    required String streamName,
    required List<int> userIds,
  }) async {
    if (userIds.isEmpty) {
      return;
    }

    final currentState = state;
    try {
      await _addSubscribersToChannelUseCase(
        AddSubscribersToChannelEntity(
          streamName: streamName,
          userIds: userIds,
        ),
      );

      if (currentState is ChannelMembersLoadedState) {
        final updatedIds = <int>{
          ...currentState.channelUsers.map((user) => user.userId),
          ...userIds,
        };
        await getUsers(updatedIds);
      }
    } catch (e) {
      rethrow;
    }
  }

  List<DmUserEntity> _mapUsersWithPresence({
    required List<UserEntity> users,
    required PresencesResponseEntity presences,
  }) {
    return users
        .map((user) {
          if (presences.presences.containsKey(user.email)) {
            final presence = presences.presences[user.email]!;
            final dmUser = user.toDmUser();
            return dmUser.copyWith(
              presenceStatus: presence.aggregated!.status,
              presenceTimestamp: presence.aggregated!.timestamp,
            );
          }
          return user.toDmUser();
        })
        .toList(growable: false);
  }
}
