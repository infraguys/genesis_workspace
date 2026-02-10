part of 'real_time_cubit.dart';

class RealTimeState {
  final bool isCheckingConnection;
  final Map<int, ConnectionEntity> connections;

  ConnectionStatus get connectionStatus {
    final selectedOrganizationId = AppConstants.selectedOrganizationId;
    return connections[selectedOrganizationId]?.status ?? .inactive;
  }

  RealTimeState({
    required this.isCheckingConnection,
    required this.connections,
  });

  RealTimeState copyWith({
    bool? isCheckingConnection,
    Map<int, ConnectionEntity>? connections,
  }) {
    return RealTimeState(
      isCheckingConnection: isCheckingConnection ?? this.isCheckingConnection,
      connections: connections ?? this.connections,
    );
  }
}
