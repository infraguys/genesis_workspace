import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart';
import 'package:injectable/injectable.dart';

part 'profile_state.dart';

@LazySingleton()
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState(user: null));

  final GetOwnUserUseCase _getOwnUserUseCase = getIt<GetOwnUserUseCase>();

  Future<void> getOwnUser() async {
    try {
      final response = await _getOwnUserUseCase.call();
      state.user = response;
      emit(state.copyWith(user: state.user));
    } catch (e) {
      inspect(e);
    }
  }
}
