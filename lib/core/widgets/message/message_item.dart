import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/message/actions_context_menu.dart';
import 'package:genesis_workspace/core/widgets/message/message_actions_overlay.dart';
import 'package:genesis_workspace/core/widgets/message/message_body.dart';
import 'package:genesis_workspace/core/widgets/message/message_call_body.dart';
import 'package:genesis_workspace/core/widgets/message/message_html.dart';
import 'package:genesis_workspace/core/widgets/message/message_reactions_list.dart';
import 'package:genesis_workspace/core/widgets/message/message_time.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

enum MessageUIOrder { first, last, middle, single, lastSingle }

class MessageItem extends StatefulWidget {
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

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final actionsPopupKey = GlobalKey<CustomPopupState>();
  late final GlobalObjectKey messageKey;

  late final MessagesCubit messagesCubit;

  bool get isRead => widget.message.flags?.contains('read') ?? false;

  bool get isStarred => widget.message.flags?.contains('starred') ?? false;

  @override
  void initState() {
    messageKey = GlobalObjectKey(widget.message);
    messagesCubit = context.read<MessagesCubit>();
    super.initState();
  }

  final parser = EmojiParser();

  void joinCall(BuildContext context) async {
    final String meetingLink = extractMeetingLink(widget.message.content);
    try {
      await Permission.camera.request();
      await Permission.microphone.request();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
    if (platformInfo.isLinux) {
      launchUrl(Uri.parse(meetingLink));
      return;
    }
    if (currentSize(context) <= ScreenSize.tablet) {
      context.pushNamed(Routes.call, extra: meetingLink);
    } else {
      String meetLocation = '';
      if (widget.message.isChannelMessage) {
        meetLocation = widget.message.displayRecipient.streamName;
      } else {
        meetLocation = widget.message.displayRecipient.recipients.map((e) => e.fullName).join(', ');
      }
      context.read<CallCubit>().openCall(meetUrl: meetingLink, meetLocationName: meetLocation);
    }
  }

  Future<void> handleToggleIsStarred(bool isStarred) async {
    try {
      if (isStarred) {
        await messagesCubit.removeStarredFlag(widget.message.id);
      } else {
        await messagesCubit.addStarredFlag(widget.message.id);
      }
    } on DioException catch (e) {
      showErrorSnackBar(context, exception: e);
    }
  }

  Future<void> handleDeleteMessage() async {
    try {
      await messagesCubit.deleteMessage(widget.message.id);
    } on DioException catch (e) {
      showErrorSnackBar(context, exception: e);
    }
  }

  Future<void> handleEmojiSelected(String emojiName) async {
    try {
      await messagesCubit.addEmojiReaction(widget.message.id, emojiName: emojiName);
    } on DioException catch (e) {
      showErrorSnackBar(context, exception: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final messageColors = Theme.of(context).extension<MessageColors>()!;

    final avatar = widget.isSkeleton
        ? const CircleAvatar(radius: 20)
        : UserAvatar(avatarUrl: widget.message.avatarUrl, size: 30);

    final messageTime = widget.isSkeleton
        ? Container(height: 10, width: 30, color: theme.colorScheme.surfaceContainerHighest)
        : Text(
            formatTime(widget.message.timestamp),
            style: theme.textTheme.bodyMedium?.copyWith(color: messageColors.timeColor),
          );

    final bool showAvatar =
        !widget.isMyMessage &&
        (widget.messageOrder == .last ||
            widget.messageOrder == .single ||
            widget.messageOrder == .lastSingle ||
            widget.isNewDay);

    final bool showSenderName =
        widget.messageOrder == .first || widget.messageOrder == .single || widget.messageOrder == .lastSingle;

    final maxMessageWidth = switch (currentSize(context)) {
      .desktop => MediaQuery.of(context).size.width * 0.55,
      .laptop => MediaQuery.of(context).size.width * 0.4,
      .sMobile => MediaQuery.of(context).size.width * 0.55,
      _ => MediaQuery.of(context).size.width * 0.6,
    };

    Color messageBgColor = switch (widget.isMyMessage) {
      _ when widget.message.isCall => messageColors.activeCallBackground,
      true => messageColors.ownBackground,
      _ => messageColors.background,
    };

    return Skeletonizer(
      enabled: widget.isSkeleton,
      child: Align(
        alignment: widget.isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: CustomPopup(
          key: actionsPopupKey,
          position: PopupPosition.auto,
          animationCurve: Curves.bounceInOut,
          contentPadding: EdgeInsets.zero,
          rootNavigator: true,
          isLongPress: true,
          contentRadius: 8,
          arrowColor: theme.colorScheme.surface,
          backgroundColor: theme.colorScheme.surface,
          content: ActionsContextMenu(
            messageId: widget.message.id,
            isMyMessage: widget.isMyMessage,
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
              widget.onTapQuote(widget.message.id);
            },
            onTapEdit: () async {
              final body = UpdateMessageRequestEntity(
                messageId: widget.message.id,
                content: widget.message.content,
              );
              // print(message.content);
              widget.onTapEditMessage(body);
            },
          ),
          child: ConstrainedBox(
            key: messageKey,
            constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).size.width * 0.9) - (widget.isMyMessage ? 30 : 0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showAvatar) ...[avatar, const SizedBox(width: 12)],
                if (!showAvatar && !widget.isMyMessage) const SizedBox(width: 44),
                GestureDetector(
                  onTap: () async {
                    inspect(widget.message.content);
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
                          message: widget.message,
                          position: position,
                          onTapQuote: () {
                            widget.onTapQuote(widget.message.id);
                          },
                          onClose: () => overlay.remove(),
                          onEdit: () {
                            final body = UpdateMessageRequestEntity(
                              messageId: widget.message.id,
                              content: widget.message.content,
                            );
                            widget.onTapEditMessage(body);
                          },
                          messageContent: MessageHtml(content: widget.message.content),
                          isOwnMessage: widget.isMyMessage,
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
                            maxWidth: (MediaQuery.sizeOf(context).width * 0.9) - (widget.isMyMessage ? 30 : 0),
                          )
                        : null,
                    decoration: BoxDecoration(
                      color: messageBgColor,
                      borderRadius: BorderRadius.circular(8).copyWith(
                        bottomRight: (widget.isMyMessage) ? Radius.zero : null,
                        bottomLeft: (!widget.isMyMessage && showAvatar) ? Radius.zero : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: widget.message.isCall ? .start : .end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.message.isCall
                                ? MessageCallBody()
                                : MessageBody(
                                    showSenderName: showSenderName,
                                    isSkeleton: widget.isSkeleton,
                                    message: widget.message,
                                    showTopic: widget.showTopic,
                                    isStarred: isStarred,
                                    actionsPopupKey: actionsPopupKey,
                                    maxMessageWidth: maxMessageWidth,
                                  ),
                            if (widget.message.aggregatedReactions.isEmpty)
                              Column(
                                crossAxisAlignment: .end,
                                children: [
                                  if (widget.message.isCall)
                                    IconButton(
                                      padding: .zero,
                                      onPressed: () {
                                        joinCall(context);
                                      },
                                      icon: Assets.icons.call.svg(
                                        width: 32,
                                        height: 32,
                                        colorFilter: ColorFilter.mode(AppColors.callGreen, BlendMode.srcIn),
                                      ),
                                    ),
                                  MessageTime(
                                    messageTime: messageTime,
                                    isMyMessage: widget.isMyMessage,
                                    isRead: isRead,
                                    isSkeleton: widget.isSkeleton,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (widget.message.aggregatedReactions.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxMessageWidth),
                                child: MessageReactionsList(
                                  message: widget.message,
                                  myUserId: widget.myUserId,
                                  maxWidth: maxMessageWidth,
                                ),
                              ),
                              Column(
                                children: [
                                  if (widget.message.isCall)
                                    IconButton(
                                      padding: .zero,
                                      onPressed: () {
                                        joinCall(context);
                                      },
                                      icon: Assets.icons.call.svg(
                                        width: 32,
                                        height: 32,
                                        colorFilter: ColorFilter.mode(AppColors.callGreen, BlendMode.srcIn),
                                      ),
                                    ),
                                  MessageTime(
                                    messageTime: messageTime,
                                    isMyMessage: widget.isMyMessage,
                                    isRead: isRead,
                                    isSkeleton: widget.isSkeleton,
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
