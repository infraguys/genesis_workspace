import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'real_time_state.dart';

@lazySingleton
class RealTimeCubit extends Cubit<RealTimeState> {
  RealTimeCubit() : super(RealTimeState());

  final RealTimeService _realTimeService = getIt<RealTimeService>();

  Future<void> init() async {
    try {
      await _realTimeService.startPolling();
    } catch (e) {
      inspect(e);
    }
  }

  void dispose() {
    _realTimeService.stopPolling();
  }
}
