enum FolderTargetType { dm, channel, group }

class FolderTarget {
  final FolderTargetType type;
  final int targetId; // userId for dm, streamId for channel
  final String? topicName; // reserved for future

  const FolderTarget.dm(this.targetId)
      : type = FolderTargetType.dm,
        topicName = null;

  const FolderTarget.channel(this.targetId, {this.topicName})
      : type = FolderTargetType.channel;

  const FolderTarget.group(this.targetId)
      : type = FolderTargetType.group,
        topicName = null;
}
