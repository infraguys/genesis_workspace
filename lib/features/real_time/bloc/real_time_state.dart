part of 'real_time_cubit.dart';

class RealTimeState {
  final bool isConnecting;

  RealTimeState({
    required this.isConnecting,
  });

  RealTimeState copyWith({
    bool? isConnecting,
  }) {
    return RealTimeState(
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}
