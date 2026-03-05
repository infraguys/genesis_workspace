import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/connection_status.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/connection_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/fcm_token_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_fcm_token_use_case.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/services/firebase/firebase_service.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'real_time_state.dart';

@lazySingleton
class RealTimeCubit extends Cubit<RealTimeState> {
  RealTimeCubit(this._multiPollingService, this._organizationsCubit, this._registerFcmTokenUseCase)
    : super(
        RealTimeState(
          isCheckingConnection: false,
          connections: {},
        ),
      ) {
    _connectionStatusSubscription = _multiPollingService.connectionStatusStream.listen(
      _onConnectionStatusChanged,
    );
  }

  final RealTimeService _realTimeService = getIt<RealTimeService>();
  final MultiPollingService _multiPollingService;
  final OrganizationsCubit _organizationsCubit;
  static const int _maxApnsTokenAttempts = 12;
  static const Duration _apnsTokenRetryDelay = Duration(milliseconds: 500);
  bool _recheckQueued = false;

  final RegisterFcmTokenUseCase _registerFcmTokenUseCase;

  late final StreamSubscription<ConnectionEntity> _connectionStatusSubscription;

  Future<void> init() async {
    try {
      await _multiPollingService.init();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> registerFcmToken() async {
    try {
      if (isFirebaseSupported && FirebaseService.isMessagingAvailable) {
        final token = await _requestFcmToken();
        await _registerFcmTokenUseCase(RegisterFcmTokenEntity(token: token));
        if (kDebugMode) {
          print("fcm token: $token");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<String> getFcmToken() async {
    if (!isFirebaseSupported) {
      throw StateError('Firebase messaging is not supported on this platform.');
    }
    if (!FirebaseService.isMessagingAvailable) {
      throw StateError('FCM is unavailable on this device. Check Google Play Services/network and try again.');
    }
    return _requestFcmToken();
  }

  Future<String> _requestFcmToken() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final isPermissionGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!isPermissionGranted) {
      throw StateError(
        'Notification permission is ${_authorizationStatusLabel(settings.authorizationStatus)}. '
        'Allow notifications in iOS Settings for this app.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken = await _safeGetApnsToken(messaging);
      for (int attempt = 0; apnsToken == null && attempt < _maxApnsTokenAttempts; attempt++) {
        await Future<void>.delayed(_apnsTokenRetryDelay);
        apnsToken = await _safeGetApnsToken(messaging);
      }
      if (apnsToken == null) {
        throw StateError(
          'APNS token was not received. Check iOS Push capability/signing/provisioning and run on a physical device.',
        );
      }
    }

    final token = await messaging.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('FCM token is empty.');
    }
    return token;
  }

  Future<String?> _safeGetApnsToken(FirebaseMessaging messaging) async {
    try {
      return await messaging.getAPNSToken();
    } catch (_) {
      return null;
    }
  }

  String _authorizationStatusLabel(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return 'authorized';
      case AuthorizationStatus.denied:
        return 'denied';
      case AuthorizationStatus.notDetermined:
        return 'notDetermined';
      case AuthorizationStatus.provisional:
        return 'provisional';
    }
  }

  Future<void> addConnection() async {
    final selectedOrganizationId = _organizationsCubit.state.selectedOrganizationId;
    final baseUrl = _organizationsCubit.state.organizations
        .firstWhere((org) => org.id == selectedOrganizationId)
        .baseUrl;
    try {
      await _multiPollingService.addConnection(selectedOrganizationId!, baseUrl);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> ensureConnection() async {
    if (state.isCheckingConnection) {
      _recheckQueued = true;
      return;
    }
    emit(state.copyWith(isCheckingConnection: true));
    try {
      await _multiPollingService.ensureAllConnections();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(isCheckingConnection: false));
      if (_recheckQueued) {
        _recheckQueued = false;
        unawaited(Future<void>.delayed(const Duration(seconds: 2), ensureConnection));
      }
    }
  }

  Future<void> disconnect() async {
    try {
      final selectedOrganizationId = _organizationsCubit.state.selectedOrganizationId;

      await _multiPollingService.closeConnection(selectedOrganizationId ?? -1);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> dispose() async {
    await _realTimeService.stopPolling();
  }

  Future<void> _onConnectionStatusChanged(ConnectionEntity entity) async {
    final updatedConnections = {...state.connections};
    updatedConnections[entity.organizationId] = entity;
    emit(state.copyWith(connections: updatedConnections));
    if (entity.status == .inactive) {
      if (state.isCheckingConnection) {
        _recheckQueued = true;
        return;
      }
      await ensureConnection();
    }
  }

  @override
  Future<void> close() async {
    _connectionStatusSubscription.cancel();
    await super.close();
  }
}
