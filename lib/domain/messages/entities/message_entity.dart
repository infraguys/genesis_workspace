import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';

class MessageEntity {
  final int id;
  final bool isMeMessage;
  final String? avatarUrl;
  final String content;
  final int senderId;
  final dynamic displayRecipient;
  final String senderFullName;
  List<String>? flags;
  final MessageType type;
  final int? streamId;
  final String subject;
  final int timestamp;
  final List<ReactionEntity> reactions;
  MessageEntity({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
    required this.type,
    this.flags,
    this.streamId,
    required this.subject,
    required this.timestamp,
    required this.reactions,
  });

  bool get hasUnreadMessages => flags == null || (flags != null && !flags!.contains('read'));

  Map<String, ReactionDetails> get aggregatedReactions {
    final Map<String, ReactionDetails> reactionMap = {};

    for (final reaction in reactions) {
      if (reactionMap.containsKey(reaction.emojiName)) {
        reactionMap[reaction.emojiName]!.count++;
        reactionMap[reaction.emojiName]!.userIds.add(reaction.userId);
      } else {
        reactionMap[reaction.emojiName] = ReactionDetails(
          count: 1,
          userIds: [reaction.userId],
          emojiName: reaction.emojiName,
          emojiCode: reaction.emojiCode,
        );
      }
    }
    return reactionMap;
  }

  MessageEntity copyWith({
    int? id,
    bool? isMeMessage,
    String? avatarUrl,
    String? content,
    int? senderId,
    String? senderFullName,
    dynamic displayRecipient,
    List<String>? flags,
    MessageType? type,
    int? streamId,
    String? subject,
    int? timestamp,
    List<ReactionEntity>? reactions,
    String? rawContent,
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
    );
  }

  /// ✅ Fake factory for skeleton/loading state
  factory MessageEntity.fake({bool isMe = false}) {
    return MessageEntity(
      id: 0,
      isMeMessage: isMe,
      avatarUrl: null,
      content: 'Loading message content...', // Placeholder text
      senderId: isMe ? 999 : 123,
      senderFullName: isMe ? 'You' : 'Sender Name',
      displayRecipient: null,
      flags: [],
      type: MessageType.stream,
      streamId: null,
      subject: 'Loading...',
      timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      reactions: [],
    );
  }
}
