import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';

class ChatEntity {
  final int id;
  final ChatType type;
  final String displayTitle;
  final String? avatarUrl;
  final int lastMessageId;
  final String lastMessagePreview;
  final String? lastMessageSenderName;
  final DateTime lastMessageDate;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final List<TopicEntity>? topics;
  final int? streamId;

  bool get isTopicsLoading => topics == null;

  ChatEntity updateLastMessage(MessageEntity message, {bool isMyMessage = false}) {
    ChatEntity updatedChat = copyWith();
    final messageDate = message.messageDate;
    final messageId = message.id;
    final messagePreview = message.content;
    final messageTopic = message.subject;
    if (!isMyMessage) {
      updatedChat = copyWith(
        displayTitle: message.displayTitle,
        avatarUrl: message.isDirectMessage ? message.avatarUrl : null,
        unreadCount: updatedChat.unreadCount + (message.isUnread ? 1 : 0),
      );
    }
    if (messageDate.isAfter(lastMessageDate)) {
      updatedChat = copyWith(
        lastMessageId: messageId,
        lastMessageDate: messageDate,
        lastMessagePreview: messagePreview,
      );
    }
    return updatedChat;
  }

  ChatEntity setChatPreview({String? avatarUrl, required String displayTitle}) {
    return copyWith(avatarUrl: avatarUrl, displayTitle: displayTitle);
  }

  factory ChatEntity.createChatFromMessage(MessageEntity message, {bool isMyMessage = false}) {
    late final ChatType type;
    if (message.isGroupChatMessage) {
      type = ChatType.groupDirect;
    } else if (message.isChannelMessage) {
      type = ChatType.channel;
    } else {
      type = ChatType.direct;
    }
    return ChatEntity(
      id: message.recipientId,
      type: type,
      displayTitle: isMyMessage ? '' : message.displayTitle,
      lastMessageId: message.id,
      lastMessagePreview: message.content,
      lastMessageDate: message.messageDate,
      unreadCount: message.isUnread ? 1 : 0,
      avatarUrl: (isMyMessage || !message.isDirectMessage) ? null : message.avatarUrl,
      isPinned: false,
      isMuted: false,
      lastMessageSenderName: message.senderFullName,
      streamId: message.streamId,
    );
  }

  ChatEntity({
    required this.id,
    required this.type,
    required this.displayTitle,
    this.avatarUrl,
    required this.lastMessageId,
    required this.lastMessagePreview,
    required this.lastMessageDate,
    required this.unreadCount,
    required this.isPinned,
    required this.isMuted,
    this.lastMessageSenderName,
    this.topics,
    this.streamId,
  });

  ChatEntity copyWith({
    int? id,
    ChatType? type,
    String? displayTitle,
    String? avatarUrl,
    int? lastMessageId,
    String? lastMessagePreview,
    DateTime? lastMessageDate,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    String? lastMessageSenderName,
    List<TopicEntity>? topics,
    int? streamId,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      displayTitle: displayTitle ?? this.displayTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      lastMessageSenderName: lastMessageSenderName ?? this.lastMessageSenderName,
      topics: topics ?? this.topics,
      streamId: streamId ?? this.streamId,
    );
  }
}
