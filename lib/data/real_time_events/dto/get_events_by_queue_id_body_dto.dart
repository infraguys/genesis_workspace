class GetEventsByQueueIdBodyDto {
  final String queueId;
  final int lastEventId;

  GetEventsByQueueIdBodyDto({required this.queueId, required this.lastEventId});

  Map<String, dynamic> toJson() => {"queue_id": queueId, "last_event_id": lastEventId};
}
