enum PushMessageKind {
  privateMessage('private_message'),
  streamChatMessage('stream_chat_message'),
  unknown('unknown');

  const PushMessageKind(this.rawValue);

  final String rawValue;

  bool get isPrivateMessage => this == PushMessageKind.privateMessage;
  bool get isStreamChatMessage => this == PushMessageKind.streamChatMessage;

  static PushMessageKind fromJson(Object? value) {
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'private_message':
      case 'private_chat_message':
      case 'dm_message':
      case 'direct_message':
        return PushMessageKind.privateMessage;
      case 'stream_chat_message':
      case 'stream_message':
        return PushMessageKind.streamChatMessage;
      default:
        return PushMessageKind.unknown;
    }
  }
}
