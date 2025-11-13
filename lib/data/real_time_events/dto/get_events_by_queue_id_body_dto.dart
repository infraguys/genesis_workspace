class GetEventsByQueueIdBodyDto {
  final String queueId;
  final int lastEventId;
  final bool dontBlock;

  GetEventsByQueueIdBodyDto({required this.queueId, required this.lastEventId, this.dontBlock = false});

  Map<String, dynamic> toJson() => {"queue_id": queueId, "last_event_id": lastEventId};
}
