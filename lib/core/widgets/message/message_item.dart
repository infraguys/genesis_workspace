import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/message/actions_context_menu.dart';
import 'package:genesis_workspace/core/widgets/message/message_actions_overlay.dart';
import 'package:genesis_workspace/core/widgets/message/message_html.dart';
import 'package:genesis_workspace/core/widgets/message/message_reactions_list.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum MessageUIOrder { first, last, middle, single, lastSingle }

class MessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageEntity message;
  final bool isSkeleton;
  final bool showTopic;
  final MessageUIOrder messageOrder;
  final int myUserId;
  final bool isNewDay;

  MessageItem({
    super.key,
    required this.isMyMessage,
    required this.message,
    this.isSkeleton = false,
    this.showTopic = false,
    this.messageOrder = MessageUIOrder.middle,
    required this.myUserId,
    this.isNewDay = false,
  });

  final actionsPopupKey = GlobalKey<CustomPopupState>();

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm').format(date);
  }

  final parser = EmojiParser();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = message.flags?.contains('read') ?? false;
    final GlobalObjectKey messageKey = GlobalObjectKey(message);

    final avatar = isSkeleton
        ? const CircleAvatar(radius: 20)
        : UserAvatar(avatarUrl: message.avatarUrl);

    final MessagesCubit messagesCubit = context.read<MessagesCubit>();
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);

    Future<void> handleEmojiSelected(String emojiName) async {
      try {
        await messagesCubit.addEmojiReaction(message.id, emojiName: emojiName);
      } on DioException catch (e) {
        final dynamic data = e.response?.data;
        final String errorMessage = (data is Map && data['msg'] is String)
            ? data['msg'] as String
            : context.t.error;
        messenger?.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    }

    Future<void> toggleIsStarred(bool isStarred) async {
      try {
        if (isStarred) {
          await messagesCubit.removeStarredFlag(message.id);
        } else {
          await messagesCubit.addStarredFlag(message.id);
        }
      } on DioException catch (e) {
        final dynamic data = e.response?.data;
        final String errorMessage = (data is Map && data['msg'] is String)
            ? data['msg'] as String
            : context.t.error;
        messenger?.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    }

    Future<void> deleteMessage() async {
      try {
        await messagesCubit.deleteMessage(message.id);
      } on DioException catch (e) {
        final dynamic data = e.response?.data;
        final String errorMessage = (data is Map && data['msg'] is String)
            ? data['msg'] as String
            : 'Failed to delete message';
        messenger?.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    }

    final messageTime = isSkeleton
        ? Container(height: 10, width: 30, color: theme.colorScheme.surfaceContainerHighest)
        : Text(
            _formatTime(message.timestamp),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          );

    final bool showAvatar =
        !isMyMessage &&
        (messageOrder == MessageUIOrder.last ||
            messageOrder == MessageUIOrder.single ||
            messageOrder == MessageUIOrder.lastSingle ||
            isNewDay);
    final bool showSenderName =
        messageOrder == MessageUIOrder.first ||
        messageOrder == MessageUIOrder.single ||
        messageOrder == MessageUIOrder.lastSingle;

    double maxMessageWidth;

    switch (currentSize(context)) {
      case ScreenSize.desktop:
        maxMessageWidth = MediaQuery.of(context).size.width * 0.55;
        break;
      case ScreenSize.laptop:
        maxMessageWidth = MediaQuery.of(context).size.width * 0.4;
        break;
      default:
        maxMessageWidth = MediaQuery.of(context).size.width * 0.7;
    }

    final bool isStarred = message.flags?.contains('starred') ?? false;

    return Skeletonizer(
      enabled: isSkeleton,
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: CustomPopup(
          key: actionsPopupKey,
          position: PopupPosition.auto,
          animationCurve: Curves.bounceInOut,
          contentPadding: EdgeInsets.zero,
          rootNavigator: true,
          isLongPress: true,
          contentDecoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          content: ActionsContextMenu(
            messageId: message.id,
            isMyMessage: isMyMessage,
            onEmojiSelected: (emojiName) async {
              await handleEmojiSelected(emojiName);
            },
            isStarred: isStarred,
            popupKey: actionsPopupKey,
            onTapStarred: () async {
              await toggleIsStarred(isStarred);
            },
            onTapDelete: () async {
              await deleteMessage();
            },
          ),
          child: ConstrainedBox(
            key: messageKey,
            constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).size.width * 0.9) - (isMyMessage ? 30 : 0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showAvatar) ...[avatar, const SizedBox(width: 4)],
                if (!showAvatar && !isMyMessage) const SizedBox(width: 44),
                GestureDetector(
                  onTap: () {
                    inspect(message.content);
                    // inspect(messageContent);
                  },
                  onSecondaryTap: () {
                    actionsPopupKey.currentState?.show();
                  },
                  onLongPress: () {
                    if (currentSize(context) <= ScreenSize.tablet) {
                      final renderBox = context.findRenderObject() as RenderBox;
                      final position = renderBox.localToGlobal(Offset.zero);

                      late OverlayEntry overlay;
                      overlay = OverlayEntry(
                        builder: (_) => MessageActionsOverlay(
                          message: message,
                          position: position,
                          onClose: () => overlay.remove(),
                          messageContent: MessageHtml(content: message.content),
                          isOwnMessage: isMyMessage,
                        ),
                      );

                      Overlay.of(context).insert(overlay);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    constraints: (showAvatar)
                        ? BoxConstraints(
                            minHeight: 40,
                            maxWidth:
                                (MediaQuery.of(context).size.width * 0.9) - (isMyMessage ? 30 : 0),
                          )
                        : null,
                    decoration: BoxDecoration(
                      color: isMyMessage
                          ? theme.colorScheme.secondaryContainer.withAlpha(128)
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14).copyWith(
                        bottomRight: isMyMessage ? Radius.zero : null,
                        bottomLeft: !isMyMessage ? Radius.zero : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MessageBody(
                                  showSenderName: showSenderName,
                                  isSkeleton: isSkeleton,
                                  message: message,
                                  showTopic: showTopic,
                                  isStarred: isStarred,
                                  actionsPopupKey: actionsPopupKey,
                                  maxMessageWidth: maxMessageWidth,
                                ),
                              ],
                            ),
                            if (message.aggregatedReactions.isNotEmpty)
                              MessageReactionsList(
                                message: message,
                                myUserId: myUserId,
                                maxWidth: maxMessageWidth,
                              ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            messageTime,
                            if (!isMyMessage && !isRead && !isSkeleton) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.circle, color: theme.colorScheme.primary, size: 8),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageBody extends StatelessWidget {
  final bool showSenderName;
  final bool isSkeleton;
  final MessageEntity message;
  final bool showTopic;
  final bool isStarred;
  final GlobalKey<CustomPopupState> actionsPopupKey;
  final double maxMessageWidth;
  const MessageBody({
    super.key,
    required this.showSenderName,
    required this.isSkeleton,
    required this.message,
    required this.showTopic,
    required this.isStarred,
    required this.actionsPopupKey,
    required this.maxMessageWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSenderName)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  isSkeleton
                      ? Container(
                          height: 10,
                          width: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                        )
                      : Text(message.senderFullName, style: theme.textTheme.titleSmall),
                  if (showTopic && message.subject.isNotEmpty)
                    Skeleton.ignore(
                      child: Row(
                        children: [
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_right, size: 16),
                          Text(message.subject, style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
              if (currentSize(context) > ScreenSize.tablet) ...[
                SizedBox(width: 4),
                _MessageActions(
                  isStarred: isStarred,
                  messageId: message.id,
                  actionsPopupKey: actionsPopupKey,
                ),
              ],
            ],
          ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxMessageWidth, minWidth: 30),
                child: isSkeleton
                    ? Container(
                        height: 14,
                        width: 150,
                        color: theme.colorScheme.surfaceContainerHighest,
                      )
                    : MessageHtml(content: message.content),
              ),
            ),
            if (currentSize(context) > ScreenSize.tablet && !showSenderName)
              _MessageActions(
                isStarred: isStarred,
                messageId: message.id,
                actionsPopupKey: actionsPopupKey,
              ),
          ],
        ),
      ],
    );
  }
}

class _MessageActions extends StatelessWidget {
  final bool isStarred;
  final int messageId;
  final GlobalKey<CustomPopupState> actionsPopupKey;
  const _MessageActions({
    super.key,
    required this.isStarred,
    required this.messageId,
    required this.actionsPopupKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              actionsPopupKey.currentState?.show();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.menu, color: theme.unselectedWidgetColor, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
