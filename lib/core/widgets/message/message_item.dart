import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/message/actions_context_menu.dart';
import 'package:genesis_workspace/core/widgets/message/message_actions_overlay.dart';
import 'package:genesis_workspace/core/widgets/message/message_body.dart';
import 'package:genesis_workspace/core/widgets/message/message_call_body.dart';
import 'package:genesis_workspace/core/widgets/message/message_html.dart';
import 'package:genesis_workspace/core/widgets/message/message_reactions_list.dart';
import 'package:genesis_workspace/core/widgets/message/message_time.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
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
  final Function(int messageId) onTapQuote;
  final Function(UpdateMessageRequestEntity body) onTapEditMessage;

  MessageItem({
    super.key,
    required this.isMyMessage,
    required this.message,
    this.isSkeleton = false,
    this.showTopic = false,
    this.messageOrder = MessageUIOrder.middle,
    required this.myUserId,
    this.isNewDay = false,
    required this.onTapQuote,
    required this.onTapEditMessage,
  });

  final actionsPopupKey = GlobalKey<CustomPopupState>();

  final parser = EmojiParser();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final messageColors = Theme.of(context).extension<MessageColors>()!;
    final isRead = message.flags?.contains('read') ?? false;
    final GlobalObjectKey messageKey = GlobalObjectKey(message);

    final avatar = isSkeleton
        ? const CircleAvatar(radius: 20)
        : UserAvatar(
            avatarUrl: message.avatarUrl,
            size: 30,
          );

    final MessagesCubit messagesCubit = context.read<MessagesCubit>();

    Future<void> handleEmojiSelected(String emojiName) async {
      try {
        await messagesCubit.addEmojiReaction(message.id, emojiName: emojiName);
      } on DioException catch (e) {
        showErrorSnackBar(context, exception: e);
      }
    }

    Future<void> handleToggleIsStarred(bool isStarred) async {
      try {
        if (isStarred) {
          await messagesCubit.removeStarredFlag(message.id);
        } else {
          await messagesCubit.addStarredFlag(message.id);
        }
      } on DioException catch (e) {
        showErrorSnackBar(context, exception: e);
      }
    }

    Future<void> handleDeleteMessage() async {
      try {
        await messagesCubit.deleteMessage(message.id);
      } on DioException catch (e) {
        showErrorSnackBar(context, exception: e);
      }
    }

    final messageTime = isSkeleton
        ? Container(height: 10, width: 30, color: theme.colorScheme.surfaceContainerHighest)
        : Text(
            formatTime(message.timestamp),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: messageColors.timeColor,
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
      case ScreenSize.sMobile:
        maxMessageWidth = MediaQuery.of(context).size.width * 0.55;
        break;
      default:
        maxMessageWidth = MediaQuery.of(context).size.width * 0.6;
    }

    final bool isStarred = message.flags?.contains('starred') ?? false;

    Color messageBgColor = messageColors.background;

    if (isMyMessage) {
      messageBgColor = messageColors.ownBackground;
    }
    if (message.isCall) {
      messageBgColor = messageColors.activeCallBackground;
    }

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
          contentRadius: 12,
          arrowColor: theme.colorScheme.surface,
          backgroundColor: theme.colorScheme.surface,
          content: ActionsContextMenu(
            messageId: message.id,
            isMyMessage: isMyMessage,
            onEmojiSelected: (emojiName) async {
              await handleEmojiSelected(emojiName);
            },
            isStarred: isStarred,
            popupKey: actionsPopupKey,
            onTapStarred: () async {
              await handleToggleIsStarred(isStarred);
            },
            onTapDelete: () async {
              await handleDeleteMessage();
            },
            onTapQuote: () {
              onTapQuote(message.id);
            },
            onTapEdit: () async {
              final body = UpdateMessageRequestEntity(
                messageId: message.id,
                content: message.content,
              );
              // print(message.content);
              onTapEditMessage(body);
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
                if (showAvatar) ...[avatar, const SizedBox(width: 12)],
                if (!showAvatar && !isMyMessage) const SizedBox(width: 44),
                GestureDetector(
                  onTap: () {
                    inspect(message.content);
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
                          onTapQuote: () {
                            onTapQuote(message.id);
                          },
                          onClose: () => overlay.remove(),
                          onEdit: () {
                            final body = UpdateMessageRequestEntity(
                              messageId: message.id,
                              content: message.content,
                            );
                            onTapEditMessage(body);
                          },
                          messageContent: MessageHtml(content: message.content),
                          isOwnMessage: isMyMessage,
                        ),
                      );

                      Overlay.of(context).insert(overlay);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: (showAvatar)
                        ? BoxConstraints(
                            minHeight: 40,
                            maxWidth: (MediaQuery.sizeOf(context).width * 0.9) - (isMyMessage ? 30 : 0),
                          )
                        : null,
                    decoration: BoxDecoration(
                      color: messageBgColor,
                      borderRadius: BorderRadius.circular(8).copyWith(
                        bottomRight: (isMyMessage) ? Radius.zero : null,
                        bottomLeft: (!isMyMessage && showAvatar) ? Radius.zero : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: message.isCall ? .start : .end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            message.isCall
                                ? MessageCallBody()
                                : MessageBody(
                                    showSenderName: showSenderName,
                                    isSkeleton: isSkeleton,
                                    message: message,
                                    showTopic: showTopic,
                                    isStarred: isStarred,
                                    actionsPopupKey: actionsPopupKey,
                                    maxMessageWidth: maxMessageWidth,
                                  ),
                            if (message.aggregatedReactions.isEmpty)
                              Column(
                                crossAxisAlignment: .end,
                                children: [
                                  if (message.isCall)
                                    Assets.icons.call.svg(
                                      width: 32,
                                      height: 32,
                                      colorFilter: ColorFilter.mode(AppColors.callGreen, BlendMode.srcIn),
                                    ),
                                  MessageTime(
                                    messageTime: messageTime,
                                    isMyMessage: isMyMessage,
                                    isRead: isRead,
                                    isSkeleton: isSkeleton,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (message.aggregatedReactions.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxMessageWidth),
                                child: MessageReactionsList(
                                  message: message,
                                  myUserId: myUserId,
                                  maxWidth: maxMessageWidth,
                                ),
                              ),
                              Column(
                                children: [
                                  Assets.icons.call.svg(
                                    width: 32,
                                    height: 32,
                                    colorFilter: ColorFilter.mode(AppColors.callGreen, BlendMode.srcIn),
                                  ),
                                  MessageTime(
                                    messageTime: messageTime,
                                    isMyMessage: isMyMessage,
                                    isRead: isRead,
                                    isSkeleton: isSkeleton,
                                  ),
                                ],
                              ),
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
