import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'real_time_state.dart';

@lazySingleton
class RealTimeCubit extends Cubit<RealTimeState> {
  RealTimeCubit() : super(RealTimeState());

  final RealTimeService realTimeService = getIt<RealTimeService>();

  init() async {
    try {
      await realTimeService.startPolling();
    } catch (e) {
      inspect(e);
    }
  }

  dispose() {
    realTimeService.stopPolling();
  }
}
