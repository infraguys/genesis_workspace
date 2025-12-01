part of 'call_cubit.dart';

class CallState {
  final bool isCallActive;
  final bool isMinimized;
  final bool isFullscreen;
  final String meetUrl;
  final Rect? dockRect;
  final String meetLocationName;

  CallState({
    required this.isCallActive,
    required this.isMinimized,
    required this.isFullscreen,
    required this.meetUrl,
    required this.dockRect,
    required this.meetLocationName,
  });

  CallState copyWith({
    bool? isCallActive,
    bool? isMinimized,
    bool? isFullscreen,
    String? meetUrl,
    Rect? dockRect,
    String? meetLocationName,
  }) {
    return CallState(
      isCallActive: isCallActive ?? this.isCallActive,
      isMinimized: isMinimized ?? this.isMinimized,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      meetUrl: meetUrl ?? this.meetUrl,
      dockRect: dockRect ?? this.dockRect,
      meetLocationName: meetLocationName ?? this.meetLocationName,
    );
  }
}
