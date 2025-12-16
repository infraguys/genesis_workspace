import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:injectable/injectable.dart';

part 'profile_state.dart';

@LazySingleton()
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getOwnUserUseCase, this._updatePresenceUseCase)
    : super(ProfileState(user: null, lastPresenceUpdateId: -1, myPresence: PresenceStatus.idle));

  final GetOwnUserUseCase _getOwnUserUseCase;
  final UpdatePresenceUseCase _updatePresenceUseCase;

  Future<void> getOwnUser() async {
    try {
      final response = await _getOwnUserUseCase.call();
      emit(state.copyWith(user: response));
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
