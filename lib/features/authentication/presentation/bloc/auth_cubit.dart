import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

@LazySingleton(dispose: disposeAuthCubit)
class AuthCubit extends Cubit<AuthState> {
  final FetchApiKeyUseCase _fetchApiKeyUseCase;
  final SaveTokenUseCase _saveTokenUseCase;
  final GetTokenUseCase _getTokenUseCase;
  final DeleteQueueUseCase _deleteQueueUseCase;
  final DeleteTokenUseCase _deleteTokenUseCase;
  final RealTimeService _realTimeService;
  final UpdatePresenceUseCase _updatePresenceUseCase;

  AuthCubit(
    this._fetchApiKeyUseCase,
    this._saveTokenUseCase,
    this._getTokenUseCase,
    this._deleteQueueUseCase,
    this._deleteTokenUseCase,
    this._realTimeService,
    this._updatePresenceUseCase,
  ) : super(const AuthState(isPending: false, isAuthorized: false));

  /// Login with basic auth -> save token -> set authorized
  Future<void> login(String username, String password) async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    try {
      final ApiKeyEntity response = await _fetchApiKeyUseCase(username, password);
      await _saveTokenUseCase(email: response.email, token: response.apiKey);

      emit(state.copyWith(isPending: false, isAuthorized: true, errorMessage: null));
    } on DioException catch (e, st) {
      final bool unauthorized = e.response?.statusCode == 401;
      final String? backendMsg = e.response?.data is Map
          ? e.response?.data['msg'] as String?
          : null;
      final String message = unauthorized
          ? (backendMsg ?? 'Invalid credentials')
          : (backendMsg ?? 'Network error. Please try again.');

      addError(e, st);
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: message));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: 'Unexpected error'));
    }
  }

  /// Graceful logout: set idle presence, drop queue, delete token
  Future<void> logout() async {
    emit(state.copyWith(isPending: true));
    try {
      final String? queueId = _realTimeService.queueId;

      final presence = UpdatePresenceRequestEntity(
        status: PresenceStatus.idle,
        newUserInput: true,
        pingOnly: true,
      );

      final futures = <Future<dynamic>>[
        _updatePresenceUseCase(presence),
        if (queueId != null) _deleteQueueUseCase(queueId),
      ];

      await Future.wait(futures);
      await _deleteTokenUseCase();

      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      // даже если что-то упало — токен лучше удалить, чтобы не зависнуть в полулогине
      await _deleteTokenUseCase();
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    }
  }

  /// Dev-only logout without network calls
  Future<void> devLogout() async {
    emit(state.copyWith(isPending: true));
    try {
      await _deleteTokenUseCase();
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(isPending: false, isAuthorized: false));
    }
  }

  /// Check persisted token to restore session on app start
  Future<void> checkToken() async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    try {
      final String? token = await _getTokenUseCase();
      emit(state.copyWith(isPending: false, isAuthorized: token != null, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(isPending: false, isAuthorized: false, errorMessage: 'Token check failed'),
      );
    }
  }
}

void disposeAuthCubit(AuthCubit cubit) => cubit.close();

class AuthState extends Equatable {
  final bool isPending;
  final bool isAuthorized;
  final String? errorMessage;

  const AuthState({required this.isPending, required this.isAuthorized, this.errorMessage});

  AuthState copyWith({bool? isPending, bool? isAuthorized, String? errorMessage}) {
    return AuthState(
      isPending: isPending ?? this.isPending,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isPending, isAuthorized, errorMessage];
}
