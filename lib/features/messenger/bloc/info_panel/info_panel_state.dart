part of 'info_panel_cubit.dart';

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
