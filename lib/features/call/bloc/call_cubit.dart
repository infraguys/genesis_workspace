import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'call_state.dart';

@injectable
class CallCubit extends Cubit<CallState> {
  CallCubit()
    : super(
        CallState(
          isCallActive: false,
          isMinimized: false,
          isFullscreen: false,
          meetUrl: '',
          dockRect: null,
          meetLocationName: '',
        ),
      );

  void openCall({required String meetUrl, required String meetLocationName}) {
    emit(
      state.copyWith(
        isCallActive: true,
        meetUrl: meetUrl,
        isMinimized: false,
        isFullscreen: false,
        dockRect: null,
        meetLocationName: meetLocationName,
      ),
    );
  }

  void closeCall() {
    emit(
      state.copyWith(
        isCallActive: false,
        isMinimized: false,
        isFullscreen: false,
        meetUrl: '',
        dockRect: null,
        meetLocationName: '',
      ),
    );
  }

  void minimizeCall() {
    if (!state.isCallActive) return;
    emit(state.copyWith(isMinimized: true, isFullscreen: false));
  }

  void restoreCall() {
    if (!state.isCallActive) return;
    emit(state.copyWith(isMinimized: false));
  }

  void toggleFullscreen() {
    if (!state.isCallActive) return;
    emit(state.copyWith(isFullscreen: !state.isFullscreen, isMinimized: false));
  }

  void updateDockRect(Rect? rect) {
    if (!state.isCallActive && rect == null) return;
    emit(state.copyWith(dockRect: rect));
  }
}
