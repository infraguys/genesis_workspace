import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum InfoPanelStatus {
  closed,
  channelInfo,
  dmInfo,
  profileInfo,
}

@injectable
class InfoPanelCubit extends Cubit<InfoPanelState> {
  InfoPanelCubit() : super(InfoPanelState(.closed));

  void setInfoPanelState(InfoPanelStatus status) {
    if (state.status != .closed) {
      emit(state.copyWith(status: .closed));
      return;
    }
    switch (status) {
      case InfoPanelStatus.closed:
        emit(state.copyWith(status: .closed));
        break;
      case InfoPanelStatus.channelInfo:
        emit(state.copyWith(status: .channelInfo));
        break;
      case InfoPanelStatus.dmInfo:
        emit(state.copyWith(status: .dmInfo));
        break;
      case InfoPanelStatus.profileInfo:
        emit(state.copyWith(status: .profileInfo));
        break;
    }
  }
}

class InfoPanelState {
  final InfoPanelStatus status;
  const InfoPanelState(this.status);

  InfoPanelState copyWith({
    InfoPanelStatus? status,
  }) {
    return InfoPanelState(
      status ?? this.status,
    );
  }
}
