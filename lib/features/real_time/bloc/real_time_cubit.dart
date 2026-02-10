import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/connection_status.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/connection_entity.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/services/firebase/firebase_service.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'real_time_state.dart';

@lazySingleton
class RealTimeCubit extends Cubit<RealTimeState> {
  RealTimeCubit(this._multiPollingService, this._organizationsCubit)
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

  late final StreamSubscription<ConnectionEntity> _connectionStatusSubscription;

  Future<void> init() async {
    try {
      if (isFirebaseSupported) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        final token = await messaging.getToken();
        // print("fcm token: ${token}");
      }
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
    try {
      await _multiPollingService.init();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
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
    emit(state.copyWith(isCheckingConnection: true));
    try {
      await _multiPollingService.ensureAllConnections();
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(isCheckingConnection: false));
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
    if (entity.status == .inactive && !state.isCheckingConnection) {
      await ensureConnection();
    }
  }

  @override
  Future<void> close() async {
    _connectionStatusSubscription.cancel();
    await super.close();
  }
}
