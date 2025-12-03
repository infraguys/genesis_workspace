import 'dart:ui';

import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
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
  final Set<int> unreadMessages;
  final bool isPinned;
  final bool isMuted;
  final List<TopicEntity>? topics;
  final int? streamId;
  final List<int>? dmIds;
  final String? colorString;

  bool get isTopicsLoading => topics == null;

  Color? get backgroundColor {
    final color = colorString;
    if (color != null) {
      try {
        return parseColor(color);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ChatEntity updateLastMessage(MessageEntity message, {bool isMyMessage = false}) {
    ChatEntity updatedChat = this;
    final messageDate = message.messageDate;
    final messageId = message.id;
    final messagePreview = message.content;
    final messageSenderName = message.senderFullName;
    if (!isMyMessage) {
      updatedChat = copyWith(
        displayTitle: message.displayTitle,
        avatarUrl: message.isDirectMessage ? message.avatarUrl : null,
      );
      if (message.isUnread) {
        updatedChat = copyWith(unreadMessages: {...updatedChat.unreadMessages, messageId});
      }
    }
    if (messageDate.isAfter(lastMessageDate)) {
      updatedChat = copyWith(
        lastMessageId: messageId,
        lastMessageDate: messageDate,
        lastMessagePreview: messagePreview,
        lastMessageSenderName: messageSenderName,
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
      displayTitle: message.displayTitle,
      lastMessageId: message.id,
      lastMessagePreview: message.content,
      lastMessageDate: message.messageDate,
      unreadMessages: message.isUnread ? {message.id} : {},
      avatarUrl: (!message.isDirectMessage) ? null : message.avatarUrl,
      isPinned: false,
      isMuted: false,
      lastMessageSenderName: message.senderFullName,
      streamId: message.streamId,
      dmIds: message.isDirectMessage || message.isGroupChatMessage
          ? message.displayRecipient.recipients.map((recipient) => recipient.userId).toList()
          : null,
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
    required this.unreadMessages,
    required this.isPinned,
    required this.isMuted,
    this.lastMessageSenderName,
    this.topics,
    this.streamId,
    this.dmIds,
    this.colorString,
  });

  ChatEntity copyWith({
    int? id,
    ChatType? type,
    String? displayTitle,
    String? avatarUrl,
    int? lastMessageId,
    String? lastMessagePreview,
    DateTime? lastMessageDate,
    Set<int>? unreadMessages,
    bool? isPinned,
    bool? isMuted,
    String? lastMessageSenderName,
    List<TopicEntity>? topics,
    int? streamId,
    List<int>? dmIds,
    String? colorString,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      displayTitle: displayTitle ?? this.displayTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      lastMessageSenderName: lastMessageSenderName ?? this.lastMessageSenderName,
      topics: topics ?? this.topics,
      streamId: streamId ?? this.streamId,
      dmIds: dmIds ?? this.dmIds,
      colorString: colorString ?? this.colorString,
    );
  }
}
