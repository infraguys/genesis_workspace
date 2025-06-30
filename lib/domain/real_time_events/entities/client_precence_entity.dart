class ClientPresenceEntity {
  final String client;
  final String status;
  final int timestamp;
  final bool pushable;

  ClientPresenceEntity({
    required this.client,
    required this.status,
    required this.timestamp,
    required this.pushable,
  });
}
