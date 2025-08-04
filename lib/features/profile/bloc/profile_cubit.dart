import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:injectable/injectable.dart';

part 'profile_state.dart';

@LazySingleton()
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState(user: null, lastPresenceUpdateId: -1));

  final GetOwnUserUseCase _getOwnUserUseCase = getIt<GetOwnUserUseCase>();
  final UpdatePresenceUseCase _updatePresenceUseCase = getIt<UpdatePresenceUseCase>();

  Future<void> getOwnUser() async {
    try {
      final response = await _getOwnUserUseCase.call();
      state.user = response;
      emit(state.copyWith(user: state.user));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> updatePresence(UpdatePresenceRequestEntity body) async {
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
