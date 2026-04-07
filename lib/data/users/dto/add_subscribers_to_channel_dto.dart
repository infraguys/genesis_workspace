class AddSubscribersToChannelDto {
  final String streamName;
  final List<int> userIds;

  AddSubscribersToChannelDto({
    required this.streamName,
    required this.userIds,
  });

  Map<String, String> get toSubscription => {"name": streamName};
}
