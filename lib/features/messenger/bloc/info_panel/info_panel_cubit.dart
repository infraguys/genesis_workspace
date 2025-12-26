import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'info_panel_state.dart';

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
    emit(state.copyWith(status: status));
  }

  void toggleProfilePanel() {
    if (state.status == .profileInfo) {
      setInfoPanelState(.closed);
    } else {
      setInfoPanelState(.profileInfo);
    }
  }
}
