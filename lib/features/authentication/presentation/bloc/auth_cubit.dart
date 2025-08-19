import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:convert/convert.dart' as conv;
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_session_id_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_csrftoken_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_server_settings_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_csrftoken_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_session_id_use_case.dart';
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
  final GetServerSettingsUseCase _getServerSettingsUseCase;
  final SaveSessionIdUseCase _saveSessionIdUseCase;
  final DeleteSessionIdUseCase _deleteSessionIdUseCase;
  final SaveCsrftokenUseCase _saveCsrftokenUseCase;
  final GetCsrftokenUseCase _getCsrftokenUseCase;

  AuthCubit(
    this._fetchApiKeyUseCase,
    this._saveTokenUseCase,
    this._getTokenUseCase,
    this._deleteQueueUseCase,
    this._deleteTokenUseCase,
    this._realTimeService,
    this._updatePresenceUseCase,
    this._getServerSettingsUseCase,
    this._saveSessionIdUseCase,
    this._deleteSessionIdUseCase,
    this._saveCsrftokenUseCase,
    this._getCsrftokenUseCase,
  ) : super(
        const AuthState(
          isPending: false,
          isAuthorized: false,
          rawKey: null,
          otp: null,
          serverSettings: null,
          errorMessage: null,
        ),
      );

  final CookieManager _cookieManager = CookieManager.instance();
  // final _dio = getIt<Dio>();
  final _dio = Dio();
  String? _csrfToken;

  final _browser = InAppBrowser();
  final _settings = InAppBrowserClassSettings(
    webViewSettings: InAppWebViewSettings(sharedCookiesEnabled: true),
  );

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

  Future<void> getServerSettings() async {
    try {
      await _deleteSessionIdUseCase.call();
      // await _cookieManager.deleteAllCookies();
      final response = await _getServerSettingsUseCase.call();

      final cookieResponse = await _dio.get('${AppConstants.baseUrl}/accounts/login/');

      final csrf = getCookieFromDio(cookieResponse.headers['set-cookie'], "__Host-csrftoken");
      _csrfToken = csrf;
      print(_csrfToken);
      // await _saveCsrftokenUseCase.call(csrftoken: csrf ?? '');
      emit(state.copyWith(serverSettings: response));
    } catch (e) {
      inspect(e);
    }
  }

  Future<String> generateOtp() async {
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();
    final keyBytes = await secretKey.extractBytes();
    final key = Uint8List.fromList(keyBytes);
    emit(state.copyWith(rawKey: key));
    final keyHex = hex.encode(key);
    return keyHex;
  }

  Future<void> startOidcMobileFlow({
    required String realmBaseUrl,
    required String loginPath,
    String next = '/',
  }) async {
    final otp = await generateOtp();
    emit(state.copyWith(otp: otp));
    final realmBase = Uri.parse(realmBaseUrl);
    final uri = Uri.parse(
      realmBase.resolve(loginPath).toString(),
    ).replace(queryParameters: {'next': next, 'desktop_flow_otp': otp});
    _cookieManager.setCookie(
      url: WebUri.uri(uri),
      name: '__Host-csrftoken',
      value: _csrfToken ?? '',
      isSecure: true,
      path: '/',
    );
    await _browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri.uri(uri)),
      settings: _settings,
    );
  }

  String? getCookieFromDio(List<String>? rawCookies, String name) {
    if (rawCookies == null) return null;

    for (final raw in rawCookies) {
      final cookie = raw.split(';').first;
      final parts = cookie.split('=');
      if (parts.length == 2 && parts.first.trim() == name) {
        return parts.last.trim();
      }
    }
    return null;
  }

  Future<void> parsePastedZulipCode({required String pastedText}) async {
    // 1) Декодируем токен
    final String token = await decryptManual(pastedText, rawKey: state.rawKey!);
    final String loginUrl = '${AppConstants.baseUrl}/accounts/login/subdomain/$token';

    final dio = Dio(
      BaseOptions(
        followRedirects: false, // важно, иначе потеряешь заголовки 302
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final response = await dio.get(loginUrl);

    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      String? csrfToken;
      String? sessionId;

      for (final cookie in cookies) {
        if (cookie.startsWith('__Host-csrftoken')) {
          csrfToken = RegExp(r'__Host-csrftoken=([^;]+)').firstMatch(cookie)?.group(1);
        } else if (cookie.startsWith('__Host-sessionid')) {
          sessionId = RegExp(r'__Host-sessionid=([^;]+)').firstMatch(cookie)?.group(1);
        }
      }

      print('csrfToken $csrfToken, sessionId $sessionId');

      await _saveCsrftokenUseCase.call(csrftoken: csrfToken ?? '');
      await _saveSessionIdUseCase.call(sessionId: sessionId ?? '');

      // сохрани куда надо (например, в state или storage)
      emit(state.copyWith(isPending: false, isAuthorized: true, errorMessage: null));
    } else {
      emit(
        state.copyWith(
          isPending: false,
          isAuthorized: false,
          errorMessage: 'Не удалось получить куки',
        ),
      );
    }
  }

  setLogin() {
    emit(state.copyWith(isPending: false, isAuthorized: true, errorMessage: null));
  }

  Future<String> decryptManual(String pastedText, {required Uint8List rawKey}) async {
    final algorithm = AesGcm.with256bits();

    // hex -> bytes
    final data = Uint8List.fromList(conv.hex.decode(pastedText.trim()));
    if (data.length < 12 + 16) {
      throw FormatException('Token too short for AES-GCM (need IV(12)+TAG(16)).');
    }

    // разбор: IV | ciphertext || tag
    final iv = data.sublist(0, 12);
    final body = data.sublist(12);
    if (body.length < 16) {
      throw FormatException('Missing GCM tag.');
    }
    final tag = body.sublist(body.length - 16);
    final ciphertext = body.sublist(0, body.length - 16);

    // расшифровка
    final clearBytes = await algorithm.decrypt(
      SecretBox(ciphertext, nonce: iv, mac: Mac(tag)),
      secretKey: SecretKey(rawKey),
    );

    return utf8.decode(clearBytes);
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
      final String? token = await _getTokenUseCase.call();
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
  final Uint8List? rawKey;

  const AuthState({
    required this.isPending,
    required this.isAuthorized,
    this.errorMessage,
    this.serverSettings,
    this.otp,
    this.rawKey,
  });

  AuthState copyWith({
    bool? isPending,
    bool? isAuthorized,
    String? errorMessage,
    ServerSettingsEntity? serverSettings,
    String? otp,
    Uint8List? rawKey,
  }) {
    return AuthState(
      isPending: isPending ?? this.isPending,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      errorMessage: errorMessage ?? this.errorMessage,
      serverSettings: serverSettings ?? this.serverSettings,
      otp: otp ?? this.otp,
      rawKey: rawKey ?? this.rawKey,
    );
  }
}
