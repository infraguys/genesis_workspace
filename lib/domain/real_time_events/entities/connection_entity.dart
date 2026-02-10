import 'package:genesis_workspace/core/enums/connection_status.dart';

class ConnectionEntity {
  final int organizationId;
  final ConnectionStatus status;
  ConnectionEntity({required this.organizationId, required this.status});
}
