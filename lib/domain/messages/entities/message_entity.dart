import 'package:equatable/equatable.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';

class MessageEntity extends Equatable {
  final int id;
  final bool isMeMessage;
  final String? avatarUrl;
  final String content;
  final int senderId;
  final String senderFullName;
  final DisplayRecipient displayRecipient;
  final List<String>? flags;
  final MessageType type;
  final int? streamId;
  final String subject;
  final int timestamp;
  final List<ReactionEntity> reactions;
  final int recipientId;

  MessageEntity({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
    required this.flags,
    required this.type,
    this.streamId,
    required this.subject,
    required this.timestamp,
    required this.reactions,
    required this.recipientId,
  });

  bool get isUnread => flags != null ? !flags!.contains('read') : true;

  bool get isDirectMessage =>
      displayRecipient is DirectMessageRecipients &&
      (displayRecipient as DirectMessageRecipients).recipients.length == 2;

  bool get isGroupChatMessage =>
      displayRecipient is DirectMessageRecipients &&
      (displayRecipient as DirectMessageRecipients).recipients.length > 2;

  bool get isChannelMessage => displayRecipient is StreamDisplayRecipient;
  bool get isTopicMessage => isChannelMessage && subject.isNotEmpty;

  String get displayTitle =>
      isChannelMessage ? (displayRecipient as StreamDisplayRecipient).streamName : senderFullName;

  DateTime get messageDate => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  bool isMyMessage(int? userId) => senderId == userId;

  Map<String, ReactionDetails> get aggregatedReactions {
    final Map<String, ReactionDetails> map = {};
    for (final reaction in reactions) {
      final key = reaction.emojiName;
      map.update(
        key,
        (value) => value
          ..count = value.count + 1
          ..userIds.add(reaction.userId),
        ifAbsent: () => ReactionDetails(
          count: 1,
          userIds: [reaction.userId],
          emojiName: reaction.emojiName,
          emojiCode: reaction.emojiCode,
        ),
      );
    }
    return map;
  }

  MessageEntity copyWith({
    int? id,
    bool? isMeMessage,
    String? avatarUrl,
    String? content,
    int? senderId,
    String? senderFullName,
    DisplayRecipient? displayRecipient,
    List<String>? flags,
    MessageType? type,
    int? streamId,
    String? subject,
    int? timestamp,
    List<ReactionEntity>? reactions,
    int? recipientId,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      isMeMessage: isMeMessage ?? this.isMeMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderFullName: senderFullName ?? this.senderFullName,
      displayRecipient: displayRecipient ?? this.displayRecipient,
      flags: flags ?? this.flags,
      type: type ?? this.type,
      streamId: streamId ?? this.streamId,
      subject: subject ?? this.subject,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      recipientId: recipientId ?? this.recipientId,
    );
  }

  factory MessageEntity.fake({bool isMe = false}) => MessageEntity(
    id: -1,
    isMeMessage: isMe,
    avatarUrl: null,
    content: 'Loading...',
    senderId: isMe ? 999 : 123,
    senderFullName: isMe ? 'You' : 'Sender',
    displayRecipient: StreamDisplayRecipient('General'),
    flags: const [],
    type: MessageType.stream,
    streamId: null,
    subject: 'Loading...',
    timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    reactions: const [],
    recipientId: -1,
  );

  @override
  List<Object?> get props => [
    id,
    isMeMessage,
    avatarUrl,
    content,
    displayRecipient,
    senderId,
    timestamp,
    flags,
    type,
    streamId,
    subject,
    reactions,
    recipientId,
  ];
}
