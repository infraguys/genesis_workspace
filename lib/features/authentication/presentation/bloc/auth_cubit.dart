import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_token_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(isPending: false, isAuthorized: false));

  final FetchApiKeyUseCase _fetchApiKeyUseCase = getIt<FetchApiKeyUseCase>();
  final SaveTokenUseCase _saveTokenUseCase = getIt<SaveTokenUseCase>();
  final GetTokenUseCase _getTokenUseCase = getIt<GetTokenUseCase>();
  final DeleteQueueUseCase _deleteQueueUseCase = getIt<DeleteQueueUseCase>();
  final DeleteTokenUseCase _deleteTokenUseCase = getIt<DeleteTokenUseCase>();
  final RealTimeService _realTimeService = getIt<RealTimeService>();
  final UpdatePresenceUseCase _updatePresenceUseCase = getIt<UpdatePresenceUseCase>();

  Future<void> login(String username, String password) async {
    state.isPending = true;
    emit(state.copyWith(isPending: state.isPending));
    try {
      final ApiKeyEntity response = await _fetchApiKeyUseCase.call(username, password);
      await _saveTokenUseCase.call(email: response.email, token: response.apiKey);
      state.isAuthorized = true;
      state.errorMessage = null;
      emit(state.copyWith(isAuthorized: state.isAuthorized, errorMessage: state.errorMessage));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state.errorMessage = e.response!.data['msg'];
        emit(state.copyWith(errorMessage: state.errorMessage));
      }
    }
    state.isPending = false;
    emit(state.copyWith(isPending: state.isPending));
  }

  Future<void> logout() async {
    final queueId = _realTimeService.queueId;
    final UpdatePresenceRequestEntity body = UpdatePresenceRequestEntity(
      status: PresenceStatus.idle,
      newUserInput: true,
      pingOnly: true,
    );
    await _updatePresenceUseCase.call(body);
    await _deleteQueueUseCase.call(queueId!);
    await _deleteTokenUseCase.call();
    state.isAuthorized = false;
    emit(state.copyWith(isAuthorized: state.isAuthorized));
  }

  Future<void> checkToken() async {
    final String? token = await _getTokenUseCase.call();
    if (token != null) {
      state.isAuthorized = true;
      emit(state.copyWith(isAuthorized: state.isAuthorized));
    } else {
      state.isAuthorized = false;
      emit(state.copyWith(isAuthorized: state.isAuthorized));
    }
  }
}

class AuthState {
  bool isPending;
  bool isAuthorized;
  String? errorMessage;

  AuthState({required this.isPending, required this.isAuthorized, this.errorMessage});

  AuthState copyWith({bool? isPending, bool? isAuthorized, String? errorMessage}) {
    return AuthState(
      isPending: isPending ?? this.isPending,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
