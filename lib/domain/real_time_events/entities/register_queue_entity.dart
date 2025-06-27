class RegisterQueueEntity {
  final String queueId;
  final String msg;
  final String result;
  final int lastEventId;

  RegisterQueueEntity({
    required this.queueId,
    required this.msg,
    required this.result,
    required this.lastEventId,
  });
}
