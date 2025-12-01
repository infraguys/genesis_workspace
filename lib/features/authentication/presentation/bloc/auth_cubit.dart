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
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/usecases/add_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_all_organizations_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_by_id_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_settings_use_case.dart';
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
import 'package:genesis_workspace/services/organizations/organization_switcher_service.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

part 'auth_state.dart';

@LazySingleton(dispose: disposeAuthCubit)
class AuthCubit extends Cubit<AuthState> {
  final FetchApiKeyUseCase _fetchApiKeyUseCase;
  final SaveTokenUseCase _saveTokenUseCase;
  final GetTokenUseCase _getTokenUseCase;
  final DeleteTokenUseCase _deleteTokenUseCase;
  final MultiPollingService _realTimeService;
  final UpdatePresenceUseCase _updatePresenceUseCase;
  final GetServerSettingsUseCase _getServerSettingsUseCase;
  final GetOrganizationSettingsUseCase _getOrganizationSettingsUseCase;
  final SaveSessionIdUseCase _saveSessionIdUseCase;
  final DeleteSessionIdUseCase _deleteSessionIdUseCase;
  final SaveCsrftokenUseCase _saveCsrftokenUseCase;
  final GetCsrftokenUseCase _getCsrftokenUseCase;
  final GetSessionIdUseCase _getSessionIdUseCase;
  final DeleteCsrftokenUseCase _deleteCsrftokenUseCase;
  final AddOrganizationUseCase _addOrganizationUseCase;
  final GetOrganizationByIdUseCase _getOrganizationByIdUseCase;
  final GetAllOrganizationsUseCase _getAllOrganizationsUseCase;
  final OrganizationSwitcherService _organizationSwitcherService;

  AuthCubit(
    this._sharedPreferences,
    this._dioFactory,
    this._fetchApiKeyUseCase,
    this._saveTokenUseCase,
    this._getTokenUseCase,
    this._deleteTokenUseCase,
    this._realTimeService,
    this._updatePresenceUseCase,
    this._getServerSettingsUseCase,
    this._getOrganizationSettingsUseCase,
    this._saveSessionIdUseCase,
    this._deleteSessionIdUseCase,
    this._saveCsrftokenUseCase,
    this._getCsrftokenUseCase,
    this._getSessionIdUseCase,
    this._deleteCsrftokenUseCase,
    this._addOrganizationUseCase,
    this._getOrganizationByIdUseCase,
    this._getAllOrganizationsUseCase,
    this._organizationSwitcherService,
  ) : super(
        AuthState(
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
          selectedOrganization: null,
        ),
      );

  final SharedPreferences _sharedPreferences;
  final DioFactory _dioFactory;
  String? _csrfToken;

  String get _baseUrl => AppConstants.baseUrl.trim();

  Future<void> refreshAuthorizationForCurrentOrganization() async {
    final String baseUrl = _baseUrl;
    if (baseUrl.isEmpty) {
      emit(state.copyWith(isAuthorized: false));
      return;
    }

    final String? token = await _getTokenUseCase.call(baseUrl);
    final String? sessionId = await _getSessionIdUseCase.call(baseUrl);
    final String? csrfToken = await _getCsrftokenUseCase.call(baseUrl);

    final bool hasCredentials =
        (token != null && token.isNotEmpty) ||
        ((sessionId != null && sessionId.isNotEmpty) && (csrfToken != null && csrfToken.isNotEmpty));

    final int? selectedOrganizationId = _sharedPreferences.getInt(
      SharedPrefsKeys.selectedOrganizationId,
    );

    final organization = await _getOrganizationByIdUseCase.call(selectedOrganizationId ?? -1);
    // await _organizationSwitcherService.selectOrganization(organization);

    emit(state.copyWith(isAuthorized: hasCredentials, selectedOrganization: organization));

    if (hasCredentials) {
      await _ensureRealTimeConnectionForOrganization(organization);
    } else {
      await getServerSettings(organization.baseUrl);
    }
  }

  Future<void> login(String username, String password) async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    try {
      final ApiKeyEntity response = await _fetchApiKeyUseCase.call(username, password);
      await _saveTokenUseCase.call(
        baseUrl: _baseUrl,
        email: response.email,
        token: response.apiKey,
      );
      final OrganizationEntity? organization = await _loadSelectedOrganization();
      await _ensureRealTimeConnectionForOrganization(organization);
      emit(state.copyWith(isAuthorized: true));
    } on DioException catch (e, st) {
      final bool unauthorized = e.response?.statusCode == 401;
      final String? backendMsg = e.response?.data is Map ? e.response?.data['msg'] as String? : null;
      final String message = unauthorized
          ? (backendMsg ?? 'Invalid credentials')
          : (backendMsg ?? 'Network error. Please try again.');

      inspect(e);
      emit(state.copyWith(isAuthorized: false, errorMessage: message));
      rethrow;
    } catch (e, st) {
      inspect(e);
      emit(state.copyWith(isAuthorized: false, errorMessage: 'Unexpected error'));
      rethrow;
    } finally {
      emit(state.copyWith(isPending: false));
    }
  }

  Future<void> getServerSettings(String url) async {
    state.serverSettings = null;
    emit(state.copyWith(serverSettingsPending: true, serverSettings: state.serverSettings));
    try {
      final response = await _getOrganizationSettingsUseCase.call(state.selectedOrganization!.baseUrl);
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

  Future<OrganizationEntity?> _loadSelectedOrganization() async {
    if (state.selectedOrganization != null) {
      return state.selectedOrganization;
    }
    final int? selectedOrganizationId = _sharedPreferences.getInt(SharedPrefsKeys.selectedOrganizationId);
    if (selectedOrganizationId == null) return null;
    try {
      return await _getOrganizationByIdUseCase.call(selectedOrganizationId);
    } catch (e) {
      inspect(e);
      return null;
    }
  }

  Future<void> _ensureRealTimeConnectionForOrganization(OrganizationEntity? organization) async {
    if (organization == null) return;
    try {
      await _realTimeService.addConnection(organization.id, organization.baseUrl);
    } catch (e) {
      inspect(e);
    }
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

      final regex = RegExp(r'name="csrfmiddlewaretoken"\s+value="([^"]+)"');
      final match = regex.firstMatch(html);

      if (match != null) {
        final csrfToken0 = match.group(1);
        await _saveCsrftokenUseCase.call(baseUrl: _baseUrl, csrftoken: csrfToken0 ?? '');
      } else {
        print('CSRF token not found');
      }

      final OrganizationEntity? organization = await _loadSelectedOrganization();
      if (kIsWeb) {
        _sharedPreferences.setBool(SharedPrefsKeys.isWebAuth, true);
        await _ensureRealTimeConnectionForOrganization(organization);
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

          await _saveCsrftokenUseCase.call(baseUrl: _baseUrl, csrftoken: csrfToken ?? '');
          await _saveSessionIdUseCase.call(baseUrl: _baseUrl, sessionId: sessionId ?? '');
        }
        await _ensureRealTimeConnectionForOrganization(organization);
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
    try {
      final presence = UpdatePresenceRequestEntity(
        status: PresenceStatus.idle,
        newUserInput: true,
        pingOnly: true,
      );

      final organizationId = AppConstants.selectedOrganizationId ?? -1;

      final futures = <Future<dynamic>>[
        _updatePresenceUseCase.call(presence),
      ];

      await Future.wait(futures);
      await _realTimeService.closeConnection(organizationId);
      await Future.wait([
        _deleteTokenUseCase.call(baseUrl: _baseUrl),
        _deleteSessionIdUseCase.call(baseUrl: _baseUrl),
        _deleteCsrftokenUseCase.call(baseUrl: _baseUrl),
      ]);
    } catch (e, st) {
      inspect(e);
      await Future.wait([
        _deleteTokenUseCase.call(baseUrl: _baseUrl),
        _deleteSessionIdUseCase.call(baseUrl: _baseUrl),
        _deleteCsrftokenUseCase.call(baseUrl: _baseUrl),
      ]);
    } finally {
      if (kIsWeb) {
        _sharedPreferences.remove(SharedPrefsKeys.isWebAuth);
      }
      emit(state.copyWith(isAuthorized: false, errorMessage: null, isPending: false));
    }
  }

  Future<void> devLogout() async {
    emit(state.copyWith(isPending: true));
    try {
      await Future.wait([
        _deleteTokenUseCase.call(baseUrl: _baseUrl),
        _deleteSessionIdUseCase.call(baseUrl: _baseUrl),
        _deleteCsrftokenUseCase.call(baseUrl: _baseUrl),
      ]);
      emit(state.copyWith(isPending: false, isAuthorized: false, errorMessage: null));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(isPending: false, isAuthorized: false));
    } finally {
      if (kIsWeb) {
        _sharedPreferences.remove(SharedPrefsKeys.isWebAuth);
      }
    }
  }

  Future<void> checkToken() async {
    emit(state.copyWith(isPending: true, errorMessage: null));
    bool isAuthorized = false;
    List<OrganizationEntity> allOrganizations = await _getAllOrganizationsUseCase.call();
    if (allOrganizations.isEmpty) {
      emit(state.copyWith(isAuthorized: false, hasBaseUrl: false, isPending: false));
      return;
    }
    final int? selectedOrganizationId = _sharedPreferences.getInt(
      SharedPrefsKeys.selectedOrganizationId,
    );
    try {
      final OrganizationEntity organization = await _getOrganizationByIdUseCase.call(
        selectedOrganizationId ?? allOrganizations[0].id,
      );
      AppConstants.setBaseUrl(organization.baseUrl);
      AppConstants.setSelectedOrganizationId(organization.id);
      emit(state.copyWith(hasBaseUrl: true, selectedOrganization: organization));

      String? token;

      for (OrganizationEntity organization in allOrganizations) {
        if (token == null) {
          final tokenResponse = await _getTokenUseCase.call(organization.baseUrl);
          token = tokenResponse;
        }
      }

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
          final String? csrf = await _getCsrftokenUseCase.call(_baseUrl);
          final String? sessionId = await _getSessionIdUseCase.call(_baseUrl);

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
    } catch (e) {
      inspect(e);
      AppConstants.setSelectedOrganizationId(null);
      emit(state.copyWith(hasBaseUrl: false, isPending: false));
    }
  }

  Future<void> saveBaseUrl({required String baseUrl}) async {
    emit(state.copyWith(pasteBaseUrlPending: true));
    try {
      final String normalizedBaseUrl = baseUrl.trim();
      AppConstants.setBaseUrl(normalizedBaseUrl);

      final dio = getIt<Dio>();
      dio.options.baseUrl = normalizedBaseUrl;

      final ServerSettingsEntity serverSettings = await _getOrganizationSettingsUseCase.call(
        baseUrl,
      );

      final organization = await _addOrganizationUseCase.call(
        OrganizationRequestEntity(
          name: serverSettings.realmName,
          icon: serverSettings.realmIcon,
          baseUrl: normalizedBaseUrl,
          unreadMessages: {},
        ),
      );

      await _sharedPreferences.setString(SharedPrefsKeys.baseUrl, organization.baseUrl);
      await _sharedPreferences.setInt(SharedPrefsKeys.selectedOrganizationId, organization.id);
      AppConstants.setSelectedOrganizationId(organization.id);

      emit(
        state.copyWith(
          hasBaseUrl: true,
          selectedOrganization: organization,
          serverSettings: serverSettings,
        ),
      );
    } catch (e, stackTrace) {
      inspect(e);
      AppConstants.setSelectedOrganizationId(null);
      emit(state.copyWith(hasBaseUrl: false, selectedOrganization: null));
    } finally {
      emit(state.copyWith(pasteBaseUrlPending: false));
    }
  }

  Future<void> clearBaseUrl() async {
    try {
      await _sharedPreferences.remove(SharedPrefsKeys.selectedOrganizationId);
      await _sharedPreferences.remove(SharedPrefsKeys.isWebAuth);
      AppConstants.setBaseUrl("");
      AppConstants.setSelectedOrganizationId(null);
    } catch (e) {
      inspect(e);
    } finally {
      emit(
        state.copyWith(
          pasteBaseUrlPending: false,
          hasBaseUrl: false,
          serverSettings: null,
          selectedOrganization: null,
        ),
      );
    }
  }
}

void disposeAuthCubit(AuthCubit cubit) => cubit.close();
