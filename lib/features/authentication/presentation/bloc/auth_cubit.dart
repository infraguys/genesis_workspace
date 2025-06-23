import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(isPending: false));

  final FetchApiKeyUseCase _fetchApiKeyUseCase = getIt<FetchApiKeyUseCase>();

  Future<void> login(String username, String password) async {
    state.isPending = true;
    emit(state.copyWith(isPending: state.isPending));
    try {
      final response = await _fetchApiKeyUseCase.call('agent@tokens.team', '6T+b09N.WYsCiV,0YOHzs');
      inspect(response);
    } catch (e) {
      inspect(e);
    }
    state.isPending = false;
    emit(state.copyWith(isPending: state.isPending));
  }
}

class AuthState {
  bool isPending;

  AuthState({required this.isPending});

  AuthState copyWith({bool? isPending}) {
    return AuthState(isPending: isPending ?? this.isPending);
  }
}
