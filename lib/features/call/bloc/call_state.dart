part of 'call_cubit.dart';

class CallState {
  final bool isCallActive;
  final bool isMinimized;
  final String meetUrl;

  CallState({required this.isCallActive, required this.isMinimized, required this.meetUrl});

  CallState copyWith({bool? isCallActive, bool? isMinimized, String? meetUrl}) {
    return CallState(
      isCallActive: isCallActive ?? this.isCallActive,
      isMinimized: isMinimized ?? this.isMinimized,
      meetUrl: meetUrl ?? this.meetUrl,
    );
  }
}
