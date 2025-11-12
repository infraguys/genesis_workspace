import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'real_time_state.dart';

@lazySingleton
class RealTimeCubit extends Cubit<RealTimeState> {
  RealTimeCubit(this._multiPollingService) : super(RealTimeState());

  final RealTimeService _realTimeService = getIt<RealTimeService>();
  final MultiPollingService _multiPollingService;

  Future<void> init() async {
    try {
      await _multiPollingService.init();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> dispose() async {
    await _realTimeService.stopPolling();
  }
}
