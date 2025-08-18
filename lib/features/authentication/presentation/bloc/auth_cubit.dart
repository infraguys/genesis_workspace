import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_server_settings_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_token_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

@LazySingleton(dispose: disposeAuthCubit)
class AuthCubit extends Cubit<AuthState> {
  final FetchApiKeyUseCase _fetchApiKeyUseCase;
  final SaveTokenUseCase _saveTokenUseCase;
  final GetTokenUseCase _getTokenUseCase;
  final DeleteQueueUseCase _deleteQueueUseCase;
  final DeleteTokenUseCase _deleteTokenUseCase;
  final RealTimeService _realTimeService;
  final UpdatePresenceUseCase _updatePresenceUseCase;
  final GetServerSettingsUseCase _getServerSettingsUseCase;

  AuthCubit(
    this._fetchApiKeyUseCase,
    this._saveTokenUseCase,
    this._getTokenUseCase,
    this._deleteQueueUseCase,
    this._deleteTokenUseCase,
    this._realTimeService,
    this._updatePresenceUseCase,
    this._getServerSettingsUseCase,
  ) : super(const AuthState(isPending: false, isAuthorized: false));

  /// Login with basic auth -> save token -> set authorized
  Future<void> login(String username, String password) async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    try {
      final ApiKeyEntity response = await _fetchApiKeyUseCase.call(username, password);
      await _saveTokenUseCase.call(email: response.email, token: response.apiKey);

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

  String generateZulipOtpHex() {
    final rnd = Random.secure();
    final bytes = Uint8List(32); // 32 байта => 64 hex-символа
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = rnd.nextInt(256);
    }
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0')); // hex нижним регистром
    }
    return sb.toString(); // длина 64, только 0-9a-f
  }

  Future<void> getServerSettings() async {
    try {
      final response = await _getServerSettingsUseCase.call();
      emit(state.copyWith(serverSettings: response));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> startOidcMobileFlow({
    required String realmBaseUrl,
    required String loginPath,
    String next = '/',
  }) async {
    final otp = generateZulipOtpHex();
    emit(state.copyWith(otp: otp));
    final realmBase = Uri.parse(realmBaseUrl);
    final uri = Uri.parse(
      realmBase.resolve(loginPath).toString(),
    ).replace(queryParameters: {'next': next, 'desktop_flow_otp': otp});
    await launchUrl(uri, mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
  }

  /// Удобный фасад для твоего Cubit/UseCase:
  Future<void> parsePastedZulipCode({required String pastedText}) async {
    final dio = getIt<Dio>();
    // final res = await dio.get('${AppConstants.baseUrl}/accounts/login/subdomain/$pastedText');
    // final res = await dio.get('zulip://$pastedText');
    await launchUrl(Uri.parse('genesis_workspace://$pastedText'));

    // final email = res.data['email'] as String;
    // final apiKey = res.data['api_key'] as String;

    // inspect(res);

    // await _saveTokenUseCase(email: email, token: apiKey);
    // emit(state.copyWith(isPending: false, isAuthorized: true, errorMessage: null));
  }

  Future<void> loginWithTokensTeam(String url) async {
    final loginUri = Uri.parse('${AppConstants.baseUrl}$url');

    if (kIsWeb) {
      // В той же вкладке (_self) или в новой (_blank)
      await launchUrl(loginUri, webOnlyWindowName: '_blank');
      return;
    }

    // Ниже — мобильные/десктоп (dart:io умеет читать редиректы)
    final dio = Dio();
    final resp = await dio.getUri(
      loginUri,
      options: Options(
        followRedirects: false,
        validateStatus: (s) => s != null && s >= 200 && s < 400,
      ),
    );

    inspect(resp);

    final location = resp.headers.value(HttpHeaders.locationHeader);
    final target = location != null ? Uri.parse(location) : loginUri;

    await launchUrl(
      target,
      // mode: LaunchMode.externalApplication, // откроет системный браузер
    );
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
        _updatePresenceUseCase.call(presence),
        if (queueId != null) _deleteQueueUseCase.call(queueId),
      ];

      await Future.wait(futures);
      await _deleteTokenUseCase.call();

      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      // даже если что-то упало — токен лучше удалить, чтобы не зависнуть в полулогине
      await _deleteTokenUseCase.call();
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

class AuthState {
  final bool isPending;
  final bool isAuthorized;
  final String? errorMessage;
  final ServerSettingsEntity? serverSettings;
  final String? otp;

  const AuthState({
    required this.isPending,
    required this.isAuthorized,
    this.errorMessage,
    this.serverSettings,
    this.otp,
  });

  AuthState copyWith({
    bool? isPending,
    bool? isAuthorized,
    String? errorMessage,
    ServerSettingsEntity? serverSettings,
    String? otp,
  }) {
    return AuthState(
      isPending: isPending ?? this.isPending,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      errorMessage: errorMessage ?? this.errorMessage,
      serverSettings: serverSettings ?? this.serverSettings,
      otp: otp ?? this.otp,
    );
  }
}
