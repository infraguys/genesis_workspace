import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/widgets/authorized_image.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/core/widgets/message_actions_overlay.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
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

  const MessageItem({
    super.key,
    required this.isMyMessage,
    required this.message,
    this.isSkeleton = false,
    this.showTopic = false,
    this.messageOrder = MessageUIOrder.middle,
    required this.myUserId,
    this.isNewDay = false,
  });

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = message.flags?.contains('read') ?? false;

    final avatar = isSkeleton
        ? const CircleAvatar(radius: 20)
        : UserAvatar(avatarUrl: message.avatarUrl);

    final senderName = isSkeleton
        ? Container(height: 10, width: 80, color: theme.colorScheme.surfaceContainerHighest)
        : Text(message.senderFullName, style: theme.textTheme.titleSmall);

    final messageContent = isSkeleton
        ? Container(height: 14, width: 150, color: theme.colorScheme.surfaceContainerHighest)
        : HtmlWidget(
            message.content,
            // factoryBuilder: () => MyWidgetFactory(),
            customStylesBuilder: (element) {
              if (element.classes.contains('user-mention')) {
                return {'font-weight': '600'};
              }
              return null;
            },
            customWidgetBuilder: (element) {
              if (element.attributes.containsValue('image/png') ||
                  element.attributes.containsValue('image/jpeg')) {
                final src = element.attributes['src'];
                final size = extractDimensionsFromUrl(src ?? '');
                return AuthorizedImage(
                  url: '${AppConstants.baseUrl}$src',
                  width: size?.width,
                  height: size?.height,
                  fit: BoxFit.contain,
                );
              }
              if (element.classes.contains('emoji')) {
                final emojiUnicode = element.classes
                    .firstWhere((className) => className.contains('emoji-'))
                    .replaceAll('emoji-', '');

                final emoji = ":${element.attributes['title']!.replaceAll(' ', '_')}:";

                return InlineCustomWidget(
                  child: UnicodeEmojiWidget(
                    emojiDisplay: UnicodeEmojiDisplay(emojiName: emoji, emojiUnicode: emojiUnicode),
                    size: 14,
                  ),
                );
              }
              return null;
            },
            onTapUrl: (String? url) async {
              print(url);
              return true;
            },
          );

    final messageTime = isSkeleton
        ? Container(height: 10, width: 30, color: theme.colorScheme.surfaceContainerHighest)
        : Text(
            _formatTime(message.timestamp),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          );

    BorderRadius? messageRadius;

    if (isMyMessage) {
      switch (messageOrder) {
        case MessageUIOrder.last:
          messageRadius = BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.zero,
          );
          break;
        case MessageUIOrder.first:
          messageRadius = BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          );
          break;
        case MessageUIOrder.single:
        case MessageUIOrder.lastSingle:
          messageRadius = BorderRadius.circular(12).copyWith(bottomRight: Radius.zero);
          break;
        case MessageUIOrder.middle:
          messageRadius = BorderRadius.zero;
          break;
      }
    } else {
      switch (messageOrder) {
        case MessageUIOrder.last:
          messageRadius = BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(12),
          );
          break;
        case MessageUIOrder.first:
          messageRadius = BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          );
          break;
        case MessageUIOrder.single:
        case MessageUIOrder.lastSingle:
          messageRadius = BorderRadius.circular(12).copyWith(bottomLeft: Radius.zero);
          break;
        case MessageUIOrder.middle:
          messageRadius = BorderRadius.zero;
          break;
      }
    }

    final bool showAvatar =
        !isMyMessage &&
            (messageOrder == MessageUIOrder.last ||
                messageOrder == MessageUIOrder.single ||
                messageOrder == MessageUIOrder.lastSingle) ||
        isNewDay;
    final bool showSenderName =
        messageOrder == MessageUIOrder.first ||
        messageOrder == MessageUIOrder.single ||
        messageOrder == MessageUIOrder.lastSingle;

    return Skeletonizer(
      enabled: isSkeleton,
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
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
                  inspect(messageContent);
                },
                onLongPress: () {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final position = renderBox.localToGlobal(Offset.zero);

                  late OverlayEntry overlay;
                  overlay = OverlayEntry(
                    builder: (_) => MessageActionsOverlay(
                      position: position,
                      onClose: () => overlay.remove(),
                      onEmojiSelected: (emojiName) async {
                        try {
                          await context.read<MessagesCubit>().addEmojiReaction(
                            message.id,
                            emojiName: emojiName,
                          );
                        } on DioException catch (e) {
                          final msg = e.response!.data['msg'];
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
                        }
                      },
                      messageId: message.id,
                      messageContent: messageContent,
                      isOwnMessage: isMyMessage,
                    ),
                  );

                  Overlay.of(context).insert(overlay);
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
                    // borderRadius: messageRadius,
                    borderRadius: BorderRadius.circular(14).copyWith(
                      bottomRight: isMyMessage ? Radius.zero : null,
                      bottomLeft: !isMyMessage ? Radius.zero : null,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showSenderName)
                                Row(
                                  children: [
                                    senderName,
                                    if (showTopic && message.subject.isNotEmpty)
                                      Skeleton.ignore(
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 2), // Spacing
                                            const Icon(Icons.arrow_right, size: 16),
                                            Text(
                                              message.subject,
                                              style: theme.textTheme.labelSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 2),
                              IntrinsicWidth(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: currentSize(context) >= ScreenSize.tablet
                                        ? MediaQuery.sizeOf(context).width * 0.6
                                        : MediaQuery.sizeOf(context).width * 0.7,
                                  ),
                                  child: messageContent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (message.aggregatedReactions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            children: message.aggregatedReactions.entries.map((entry) {
                              final ReactionDetails reaction = entry.value;
                              final bool isMyReaction = reaction.userIds.contains(myUserId);

                              return GestureDetector(
                                onTap: () async {
                                  final String emojiIdentifier = entry.key;
                                  if (isMyReaction) {
                                    await context.read<MessagesCubit>().removeEmojiReaction(
                                      message.id,
                                      emojiName: emojiIdentifier,
                                    );
                                  } else {
                                    await context.read<MessagesCubit>().addEmojiReaction(
                                      message.id,
                                      emojiName: emojiIdentifier,
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isMyReaction
                                        ? theme.colorScheme.primaryFixedDim
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: isMyReaction
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outlineVariant,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      UnicodeEmojiWidget(
                                        emojiDisplay: UnicodeEmojiDisplay(
                                          emojiName: reaction.emojiName,
                                          emojiUnicode: reaction.emojiCode,
                                        ),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        reaction.count.toString(),
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: isMyReaction
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
    );
  }
}

// class MyWidgetFactory extends WidgetFactory with CachedNetworkImageFactory {}
