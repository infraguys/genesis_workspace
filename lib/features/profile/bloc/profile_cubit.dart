import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/update_my_status_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_status_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_status_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/update_my_status_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:injectable/injectable.dart';

part 'profile_state.dart';

@LazySingleton()
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getOwnUserUseCase,
    this._updatePresenceUseCase,
    this._getUserStatusUseCase,
    this._updateMyStatusUseCase,
  ) : super(ProfileState(user: null, lastPresenceUpdateId: -1, myPresence: PresenceStatus.idle));

  final GetOwnUserUseCase _getOwnUserUseCase;
  final GetUserStatusUseCase _getUserStatusUseCase;
  final UpdateMyStatusUseCase _updateMyStatusUseCase;
  final UpdatePresenceUseCase _updatePresenceUseCase;

  Future<void> getOwnUser() async {
    try {
      final user = await _getOwnUserUseCase.call();
      final statusResponse = await _getUserStatusUseCase.call(UserStatusRequestEntity(userId: user.userId));
      final userWithStatus = user.copyWith(
        status: statusResponse,
      );
      emit(state.copyWith(user: userWithStatus));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> updateStatus(UpdateMyStatusRequestEntity body) async {
    try {
      await _updateMyStatusUseCase.call(body);
      final user = state.user;
      if (user == null) {
        return;
      }

      String? normalizeStatusValue(String? value) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return null;
        }
        return trimmed;
      }

      final updatedStatus = UserStatusEntity(
        statusText: normalizeStatusValue(body.statusText),
        emojiName: normalizeStatusValue(body.emojiName),
        emojiCode: normalizeStatusValue(body.emojiCode),
      );

      emit(state.copyWith(user: user.copyWith(status: updatedStatus)));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> updatePresence(UpdatePresenceRequestEntity body) async {
    if (state.myPresence != body.status) {
      state.myPresence = body.status;
      try {
        body.lastUpdateId = state.lastPresenceUpdateId;
        final response = await _updatePresenceUseCase.call(body);
        if (response.presenceLastUpdateId != null) {
          state.lastPresenceUpdateId = response.presenceLastUpdateId!;
        }
      } catch (e) {
        inspect(e);
      }
    }
  }
}
