import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'real_time_state.dart';

@lazySingleton
class RealTimeCubit extends Cubit<RealTimeState> {
  RealTimeCubit(this._multiPollingService, this._organizationsCubit) : super(RealTimeState());

  final RealTimeService _realTimeService = getIt<RealTimeService>();
  final MultiPollingService _multiPollingService;
  final OrganizationsCubit _organizationsCubit;

  Future<void> init() async {
    try {
      await _multiPollingService.init();
    } catch (e) {
      inspect(e);
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
    try {
      await _multiPollingService.ensureAllConnections();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> dispose() async {
    await _realTimeService.stopPolling();
  }
}
