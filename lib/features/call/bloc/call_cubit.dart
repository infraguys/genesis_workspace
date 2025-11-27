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
          meetUrl: '',
        ),
      );

  void openCall(String meetUrl) {
    emit(state.copyWith(isCallActive: true, meetUrl: meetUrl, isMinimized: false));
  }

  void closeCall() {
    emit(state.copyWith(isCallActive: false, isMinimized: false, meetUrl: ''));
  }
}
