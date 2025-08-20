import 'dart:async';
import 'dart:convert';
import 'dart:developer';

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
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_csrftoken_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_session_id_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_csrftoken_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_server_settings_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_session_id_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_csrftoken_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_session_id_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/save_token_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final SaveSessionIdUseCase _saveSessionIdUseCase;
  final DeleteSessionIdUseCase _deleteSessionIdUseCase;
  final SaveCsrftokenUseCase _saveCsrftokenUseCase;
  final GetCsrftokenUseCase _getCsrftokenUseCase;
  final GetSessionIdUseCase _getSessionIdUseCase;
  final DeleteCsrftokenUseCase _deleteCsrftokenUseCase;

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
    this._getSessionIdUseCase,
    this._deleteCsrftokenUseCase,
  ) : super(
        const AuthState(
          isPending: false,
          isAuthorized: false,
          rawKey: null,
          otp: null,
          serverSettings: null,
          errorMessage: null,
          isParseTokenPending: false,
          parseTokenError: null,
        ),
      );

  late final SharedPreferences _prefs;
  final CookieManager _cookieManager = CookieManager.instance();
  final Dio _dio = Dio();
  String? _csrfToken;

  final InAppBrowser? _browser = kIsWeb ? null : InAppBrowser();
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
      final response = await _getServerSettingsUseCase.call();
      final cookieResponse = await _dio.get('${AppConstants.baseUrl}/accounts/login/');
      final csrf = _getCookieFromDio(cookieResponse.headers['set-cookie'], "__Host-csrftoken");
      _csrfToken = csrf;

      emit(state.copyWith(serverSettings: response));
    } catch (e) {
      inspect(e);
    }
  }

  Future<String> _generateOtp() async {
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
    final otp = await _generateOtp();
    emit(state.copyWith(otp: otp));
    final realmBase = Uri.parse(realmBaseUrl);
    final uri = Uri.parse(
      realmBase.resolve(loginPath).toString(),
    ).replace(queryParameters: {'next': next, 'desktop_flow_otp': otp});
    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      _cookieManager.setCookie(
        url: WebUri.uri(uri),
        name: '__Host-csrftoken',
        value: _csrfToken ?? '',
        isSecure: true,
        path: '/',
      );
      await _browser!.openUrlRequest(
        urlRequest: URLRequest(url: WebUri.uri(uri)),
        settings: _settings,
      );
    }
  }

  String? _getCookieFromDio(List<String>? rawCookies, String name) {
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

  setLogin() {
    emit(state.copyWith(isAuthorized: true));
  }

  Future<void> parsePastedZulipCode({required String pastedText}) async {
    emit(state.copyWith(isParseTokenPending: true));
    try {
      // 1) Декодируем токен
      final String token = await _decryptManual(pastedText, rawKey: state.rawKey!);
      final String loginUrl = '${AppConstants.baseUrl}/accounts/login/subdomain/$token';

      final dio = Dio(
        BaseOptions(
          followRedirects: false, // важно, иначе потеряешь заголовки 302
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      final response = await dio.get(loginUrl);

      if (kIsWeb) {
        _prefs.setBool(SharedPrefsKeys.isWebAuth, true);
        emit(state.copyWith(isAuthorized: true, errorMessage: null));
      } else {
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

          await _saveCsrftokenUseCase.call(csrftoken: csrfToken ?? '');
          await _saveSessionIdUseCase.call(sessionId: sessionId ?? '');
        }
        emit(state.copyWith(isAuthorized: true, errorMessage: null));
      }
    } on FormatException catch (e) {
      inspect(e);
      emit(state.copyWith(parseTokenError: e.message));
    } on DioException catch (e) {
      inspect(e);
      emit(state.copyWith(parseTokenError: 'Invalid or expired login session. Try again.'));
    } finally {
      emit(state.copyWith(isParseTokenPending: false));
    }
  }

  Future<String> _decryptManual(String pastedText, {required Uint8List rawKey}) async {
    final algorithm = AesGcm.with256bits();

    // hex -> bytes
    final data = Uint8List.fromList(hex.decode(pastedText.trim()));
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
    if (kIsWeb) {
      _prefs.remove(SharedPrefsKeys.isWebAuth);
    }
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
      await Future.wait([
        _deleteTokenUseCase.call(),
        _deleteSessionIdUseCase.call(),
        _deleteCsrftokenUseCase.call(),
      ]);
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      // даже если что-то упало — токен лучше удалить, чтобы не зависнуть в полулогине
      await Future.wait([
        _deleteTokenUseCase.call(),
        _deleteSessionIdUseCase.call(),
        _deleteCsrftokenUseCase.call(),
      ]);
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    }
  }

  /// Dev-only logout without network calls
  Future<void> devLogout() async {
    emit(state.copyWith(isPending: true));
    try {
      await Future.wait([
        _deleteTokenUseCase.call(),
        _deleteSessionIdUseCase.call(),
        _deleteCsrftokenUseCase.call(),
      ]);
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(isPending: false, isAuthorized: false));
    }
  }

  /// Check persisted token to restore session on app start
  Future<void> checkToken() async {
    _prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(isPending: true, errorMessage: null));
    if (kIsWeb) {
      final isAuth = _prefs.getBool(SharedPrefsKeys.isWebAuth) ?? false;
      emit(state.copyWith(isAuthorized: isAuth, errorMessage: null, isPending: false));
      return;
    }
    try {
      final String? token = await _getTokenUseCase.call();
      final String? csrf = await _getCsrftokenUseCase.call();
      final String? sessionId = await _getSessionIdUseCase.call();
      bool isAuthorized = false;

      if (token != null) {
        isAuthorized = true;
      } else if (csrf != null && sessionId != null) {
        isAuthorized = true;
      }

      emit(state.copyWith(isPending: false, isAuthorized: isAuthorized, errorMessage: null));
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
  final bool isParseTokenPending;
  final String? parseTokenError;

  const AuthState({
    required this.isPending,
    required this.isAuthorized,
    this.errorMessage,
    this.serverSettings,
    this.otp,
    this.rawKey,
    required this.isParseTokenPending,
    this.parseTokenError,
  });

  AuthState copyWith({
    bool? isPending,
    bool? isAuthorized,
    String? errorMessage,
    ServerSettingsEntity? serverSettings,
    String? otp,
    Uint8List? rawKey,
    bool? isParseTokenPending,
    String? parseTokenError,
  }) {
    return AuthState(
      isPending: isPending ?? this.isPending,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      errorMessage: errorMessage ?? this.errorMessage,
      serverSettings: serverSettings ?? this.serverSettings,
      otp: otp ?? this.otp,
      rawKey: rawKey ?? this.rawKey,
      isParseTokenPending: isParseTokenPending ?? this.isParseTokenPending,
      parseTokenError: parseTokenError ?? this.parseTokenError,
    );
  }
}
