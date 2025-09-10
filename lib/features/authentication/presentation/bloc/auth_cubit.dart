import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/core_module.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
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
    this._sharedPreferences,
    this._dioFactory,
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
          hasBaseUrl: false,
          pasteBaseUrlPending: false,
          serverSettingsPending: false,
          currentBaseUrl: null,
        ),
      );

  final SharedPreferences _sharedPreferences;
  final DioFactory _dioFactory;
  String? _csrfToken;

  Future<void> login(String username, String password) async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    try {
      final ApiKeyEntity response = await _fetchApiKeyUseCase.call(username, password);
      await _saveTokenUseCase.call(email: response.email, token: response.apiKey);

      emit(state.copyWith(isAuthorized: true, errorMessage: null));
    } on DioException catch (e, st) {
      final bool unauthorized = e.response?.statusCode == 401;
      final String? backendMsg = e.response?.data is Map
          ? e.response?.data['msg'] as String?
          : null;
      final String message = unauthorized
          ? (backendMsg ?? 'Invalid credentials')
          : (backendMsg ?? 'Network error. Please try again.');

      inspect(e);
      emit(state.copyWith(isAuthorized: false, errorMessage: message));
    } catch (e, st) {
      inspect(e);
      emit(state.copyWith(isAuthorized: false, errorMessage: 'Unexpected error'));
    } finally {
      emit(state.copyWith(isPending: false));
    }
  }

  Future<void> getServerSettings() async {
    emit(state.copyWith(serverSettingsPending: true));
    try {
      await _deleteSessionIdUseCase.call();
      final response = await _getServerSettingsUseCase.call();

      emit(state.copyWith(serverSettings: response));
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(serverSettingsPending: false));
    }
    final dio = getIt<Dio>();
    final cookieResponse = await dio.get('${AppConstants.baseUrl}/accounts/login/');
    final csrf = _getCookieFromDio(cookieResponse.headers['set-cookie'], "__Host-csrftoken");
    _csrfToken = csrf;
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
    if (true) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
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
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      final response = await dio.get(loginUrl);
      final zulipResponse = await dio.get('${AppConstants.baseUrl}${AppConstants.legacyPath}');
      final html = zulipResponse.data as String;
      print(html);

      final regex = RegExp(r'name="csrfmiddlewaretoken"\s+value="([^"]+)"');
      final match = regex.firstMatch(html);

      if (match != null) {
        final csrfToken0 = match.group(1);
        await _saveCsrftokenUseCase.call(csrftoken: csrfToken0 ?? '');
      } else {
        print('CSRF token not found');
      }

      if (kIsWeb) {
        _sharedPreferences.setBool(SharedPrefsKeys.isWebAuth, true);
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

    final data = Uint8List.fromList(hex.decode(pastedText.trim()));
    if (data.length < 12 + 16) {
      throw FormatException('Token too short for AES-GCM (need IV(12)+TAG(16)).');
    }

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

  Future<void> logout() async {
    emit(state.copyWith(isPending: true));
    if (kIsWeb) {
      _sharedPreferences.remove(SharedPrefsKeys.isWebAuth);
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
      await _realTimeService.stopPolling();
      await Future.wait([
        _deleteTokenUseCase.call(),
        _deleteSessionIdUseCase.call(),
        _deleteCsrftokenUseCase.call(),
      ]);
    } catch (e, st) {
      inspect(e);
      await Future.wait([
        _deleteTokenUseCase.call(),
        _deleteSessionIdUseCase.call(),
        _deleteCsrftokenUseCase.call(),
      ]);
    } finally {
      emit(state.copyWith(isAuthorized: false, errorMessage: null, isPending: false));
    }
  }

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

  Future<void> checkToken() async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    bool isAuthorized = false;
    final String? baseUrl = _sharedPreferences.getString(SharedPrefsKeys.baseUrl);
    if (baseUrl != null) {
      emit(state.copyWith(hasBaseUrl: true, currentBaseUrl: baseUrl));
      final String? token = await _getTokenUseCase.call();

      if (token != null) {
        isAuthorized = true;
        emit(state.copyWith(isPending: false, isAuthorized: isAuthorized, errorMessage: null));
      } else {
        if (kIsWeb) {
          final isAuth = _sharedPreferences.getBool(SharedPrefsKeys.isWebAuth) ?? false;
          emit(state.copyWith(isAuthorized: isAuth, errorMessage: null, isPending: false));
          return;
        }
        try {
          final String? csrf = await _getCsrftokenUseCase.call();
          final String? sessionId = await _getSessionIdUseCase.call();

          if (csrf != null && sessionId != null) {
            isAuthorized = true;
          }
          emit(state.copyWith(errorMessage: null));
        } catch (e, st) {
          addError(e, st);
          emit(state.copyWith(isAuthorized: false, errorMessage: 'Token check failed'));
        } finally {
          emit(state.copyWith(isPending: false, isAuthorized: isAuthorized));
        }
      }
    } else {
      emit(state.copyWith(hasBaseUrl: false, isPending: false));
    }
  }

  Future<void> saveBaseUrl({required String baseUrl}) async {
    emit(state.copyWith(pasteBaseUrlPending: true));
    try {
      final String normalized = baseUrl.trim();
      await _sharedPreferences.setString(SharedPrefsKeys.baseUrl, normalized);
      AppConstants.setBaseUrl(normalized);

      final dio = getIt<Dio>();
      dio.options.baseUrl = normalized;
      emit(state.copyWith(hasBaseUrl: true, currentBaseUrl: normalized));
    } catch (e) {
      inspect(e);
      emit(state.copyWith(hasBaseUrl: false, currentBaseUrl: null));
    } finally {
      emit(state.copyWith(pasteBaseUrlPending: false));
    }
  }

  Future<void> clearBaseUrl() async {
    try {
      await _sharedPreferences.remove(SharedPrefsKeys.baseUrl);
      AppConstants.setBaseUrl("");
      await _sharedPreferences.remove(SharedPrefsKeys.isWebAuth);
    } catch (e) {
      inspect(e);
    } finally {
      emit(
        state.copyWith(
          pasteBaseUrlPending: false,
          hasBaseUrl: false,
          serverSettings: null,
          currentBaseUrl: null,
        ),
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
  final bool hasBaseUrl;
  final bool pasteBaseUrlPending;
  final bool serverSettingsPending;
  final String? currentBaseUrl;

  const AuthState({
    required this.isPending,
    required this.isAuthorized,
    this.errorMessage,
    this.serverSettings,
    this.otp,
    this.rawKey,
    required this.isParseTokenPending,
    this.parseTokenError,
    required this.hasBaseUrl,
    required this.pasteBaseUrlPending,
    required this.serverSettingsPending,
    this.currentBaseUrl,
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
    bool? hasBaseUrl,
    bool? pasteBaseUrlPending,
    bool? serverSettingsPending,
    String? currentBaseUrl,
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
      hasBaseUrl: hasBaseUrl ?? this.hasBaseUrl,
      pasteBaseUrlPending: pasteBaseUrlPending ?? this.pasteBaseUrlPending,
      serverSettingsPending: serverSettingsPending ?? this.serverSettingsPending,
      currentBaseUrl: currentBaseUrl ?? this.currentBaseUrl,
    );
  }
}
