import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/core/mixins/message/forward_message_mixin.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/message/message_body.dart';
import 'package:genesis_workspace/core/widgets/message/message_call_body.dart';
import 'package:genesis_workspace/core/widgets/message/message_context_menu.dart';
import 'package:genesis_workspace/core/widgets/message/message_reactions_list.dart';
import 'package:genesis_workspace/core/widgets/message/message_time.dart';
import 'package:genesis_workspace/core/widgets/message/selection_indicator.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages/messages_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum MessageUIOrder { first, last, middle, single, lastSingle }

class MessageItem extends StatefulWidget {
  const MessageItem({
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
    this.isSelectMode = false,
    this.isSelected = false,
    this.isFocused = false,
  });

  final bool isMyMessage;
  final MessageEntity message;
  final bool isSkeleton;
  final bool showTopic;
  final MessageUIOrder messageOrder;
  final int myUserId;
  final bool isNewDay;
  final bool isSelectMode;
  final bool isSelected;
  final void Function(int messageId, {String? quote}) onTapQuote;
  final Function(UpdateMessageRequestEntity body) onTapEditMessage;
  final bool isFocused;

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> with ForwardMessageMixin, OpenChatMixin {
  late final GlobalObjectKey messageKey;
  late final MenuController _menuController;

  static OverlayEntry? _menuEntry;

  late final MessagesCubit messagesCubit;

  static const double _contextMenuScale = 0.98;
  static const Duration _contextMenuScaleDuration = Duration(milliseconds: 120);

  double _messageScale = 1.0;

  bool get isRead => widget.message.flags?.contains('read') ?? false;

  bool get isStarred => widget.message.flags?.contains('starred') ?? false;

  String selectedText = '';

  Offset? _touchDownPosition;
  bool _touchMoved = false;

  static const double _tapSlop = 6.0;

  onSelectedTextChanged(String value) {
    selectedText = value;
  }

  @override
  void initState() {
    messageKey = GlobalObjectKey(widget.message);
    messagesCubit = context.read<MessagesCubit>();
    _menuController = MenuController();
    super.initState();
  }

  @override
  void dispose() {
    _menuController.close();
    super.dispose();
  }

  void joinCall(BuildContext context) async {
    final String meetingLink = extractMeetingLink(widget.message.content);
    final Uri? meetingUri = parseUrlWithBase(meetingLink);
    if (meetingUri == null || !isAllowedUrlScheme(meetingUri, allowContactSchemes: false)) {
      return;
    }

    final String normalizedMeetingLink = meetingUri.toString();
    final screenSize = currentSize(context);
    final router = GoRouter.of(context);
    try {
      await Permission.camera.request();
      await Permission.microphone.request();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
    if (platformInfo.isLinux) {
      await launchUrlSafely(context, meetingUri, allowContactSchemes: false);
      return;
    }
    if (screenSize <= .tablet) {
      router.pushNamed(Routes.call, extra: normalizedMeetingLink);
    } else {
      String meetLocation = '';
      if (widget.message.isChannelMessage) {
        meetLocation = widget.message.displayRecipient.streamName;
      } else {
        meetLocation = widget.message.displayRecipient.recipients.map((e) => e.fullName).join(', ');
      }
      context.read<CallCubit>().openCall(meetUrl: normalizedMeetingLink, meetLocationName: meetLocation);
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

  void onEditMessage() {
    final body = UpdateMessageRequestEntity(messageId: widget.message.id, content: widget.message.content);
    widget.onTapEditMessage(body);
    _menuController.close();
  }

  void onReplay() {
    if (widget.isSelectMode) return;
    widget.onTapQuote(widget.message.id, quote: selectedText.isNotEmpty ? selectedText : null);
    _menuController.close();
  }

  void onSelect() {
    context.read<MessagesSelectCubit>().setSelectMode(true, selectedMessage: widget.message);
    _menuController.close();
  }

  void onGoToMessage() {
    if (widget.message.displayRecipient is DirectMessageRecipients) {
      final memberIds = widget.message.displayRecipient.recipients.map((e) => e.userId).toSet();
      openChat(
        context,
        membersIds: memberIds,
        chatId: widget.message.recipientId,
        focusedMessageId: widget.message.id,
      );
    } else {
      final channelId = widget.message.streamId!;
      openChannel(
        context,
        channelId: channelId,
        topicName: widget.message.subject,
        focusedMessageId: widget.message.id,
      );
    }
    _menuController.close();
  }

  void onCopy() async {
    final message = await messagesCubit.getMessageById(messageId: widget.message.id, applyMarkdown: false);
    await Clipboard.setData(ClipboardData(text: message.content));
  }

  void _closeOverlay() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _openContextMenu(BuildContext context, Offset globalPosition) {
    _closeOverlay();

    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }

    final localInOverlay = overlayBox.globalToLocal(globalPosition);
    _menuEntry = OverlayEntry(
      builder: (context) {
        return MessageContextMenu(
          messageId: widget.message.id,
          offset: localInOverlay,
          isStarred: isStarred,
          isMyMessage: widget.isMyMessage,
          onReply: onReplay,
          onEdit: widget.isMyMessage ? onEditMessage : null,
          onCopy: onCopy,
          onToggleStar: () async => await handleToggleIsStarred(isStarred),
          onDelete: widget.isMyMessage ? handleDeleteMessage : null,
          onEmojiSelected: (emoji) async => await handleEmojiSelected(emoji),
          onClose: _closeOverlay,
          onForward: () {
            onForward(
              context,
              closeOverlay: () {
                _closeOverlay();
                _menuController.close();
              },
              message: widget.message,
              quote: selectedText.isNotEmpty ? selectedText : null,
            );
          },
          onSelect: onSelect,
          onGoToMessage: onGoToMessage,
        );
      },
    );

    overlay.insert(_menuEntry!);
  }

  Future<void> _animateMessageContainer() async {
    if (!mounted) return;
    setState(() {
      _messageScale = _contextMenuScale;
    });
    await Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _messageScale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageColors = Theme.of(context).extension<MessageColors>()!;

    final avatar = widget.isSkeleton
        ? const CircleAvatar(radius: 15)
        : UserAvatar(avatarUrl: widget.message.avatarUrl, size: 30);

    final messageTime = widget.isSkeleton
        ? Container(height: 10, width: 30, color: theme.colorScheme.surfaceContainerHighest)
        : Text(
            formatTime(widget.message.timestamp),
            style: theme.textTheme.bodyMedium?.copyWith(color: messageColors.timeColor),
          );

    final bool showAvatar = switch (widget.messageOrder) {
      _ when widget.isMyMessage => false,
      _ when widget.isSkeleton => true,
      _ when widget.isSelectMode => false,
      _ when widget.isNewDay => true,
      .last || .single || .lastSingle => true,
      _ => false,
    };

    final Widget messageLeading = widget.isSelectMode
        ? SelectionIndicator(
            isSelected: widget.isSelected,
          )
        : const SizedBox(
            width: 30,
          );

    final bool showSenderName = switch (widget.messageOrder) {
      .first || .single || .lastSingle => true,
      _ => false,
    };

    Color messageBgColor = switch (widget.isMyMessage) {
      _ when widget.isFocused => theme.colorScheme.primary,
      _ when widget.message.isCall => messageColors.activeCallBackground,
      true => messageColors.ownBackground,
      _ => messageColors.background,
    };

    return LayoutBuilder(
      builder: (context, constrains) {
        final maxWidthMessage = switch (currentSize(context)) {
          .desktop => constrains.maxWidth * 0.8,
          .laptop => constrains.maxWidth * 0.7,
          _ => constrains.maxWidth * 0.6,
        };
        return Skeletonizer(
          enabled: widget.isSkeleton,
          child: MouseRegion(
            cursor: widget.isSelectMode ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: Listener(
              behavior: widget.isSelectMode ? .translucent : .deferToChild,
              onPointerDown: (event) {
                final isMouse = event.kind == PointerDeviceKind.mouse;
                final isRightClick = isMouse && event.buttons == kSecondaryMouseButton;

                if (isMouse && event.buttons == kPrimaryMouseButton && widget.isSelectMode) {
                  context.read<MessagesSelectCubit>().toggleMessageSelection(widget.message);
                }

                // ✅ Desktop context menu
                if (isRightClick && !widget.isSelectMode) {
                  _openContextMenu(context, event.position);
                  return;
                }

                // ✅ Mobile tap-detection for select-mode
                if (!widget.isSelectMode) return;
                if (event.kind != PointerDeviceKind.touch) return;
                if (event.buttons != kPrimaryMouseButton) return;

                _touchDownPosition = event.position;
                _touchMoved = false;
              },
              onPointerMove: (event) {
                if (!widget.isSelectMode) return;
                if (_touchDownPosition == null) return;

                final movedDistance = (event.position - _touchDownPosition!).distance;
                if (movedDistance > _tapSlop) {
                  _touchMoved = true;
                }
              },
              onPointerUp: (event) {
                if (!widget.isSelectMode) return;
                if (event.kind != PointerDeviceKind.touch) return;
                if (event.buttons != 0) return; // up

                if (!_touchMoved) {
                  context.read<MessagesSelectCubit>().toggleMessageSelection(widget.message);
                }

                _touchDownPosition = null;
                _touchMoved = false;
              },
              onPointerCancel: (_) {
                _touchDownPosition = null;
                _touchMoved = false;
              },
              child: GestureDetector(
                onLongPressStart: (details) {
                  if (widget.isSelectMode) return;
                  if (platformInfo.isMobile) {
                    _animateMessageContainer();
                    final FocusNode? currentFocus = FocusManager.instance.primaryFocus;
                    if (currentFocus != null && currentFocus.hasFocus) {
                      currentFocus.unfocus();
                    }
                    HapticFeedback.mediumImpact();
                    _openContextMenu(context, details.globalPosition);
                  }
                },
                onDoubleTap: onReplay,
                child: Align(
                  alignment: widget.isMyMessage ? .centerRight : .centerLeft,
                  child: Row(
                    mainAxisSize: widget.isSelectMode ? .max : .min,
                    crossAxisAlignment: .end,
                    spacing: 12,
                    children: [
                      showAvatar ? avatar : messageLeading,
                      if (widget.isSelectMode && widget.isMyMessage) Spacer(),
                      AnimatedScale(
                        scale: _messageScale,
                        duration: _contextMenuScaleDuration,
                        curve: Curves.easeOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
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
                              bottomRight: (widget.isMyMessage) ? .zero : null,
                              bottomLeft: (!widget.isMyMessage && showAvatar) ? .zero : null,
                            ),
                          ),
                          foregroundDecoration: (widget.isSelected && widget.isSelectMode)
                              ? BoxDecoration(
                                  color: messageColors.selectedMessageForeground,
                                  borderRadius: BorderRadius.circular(8).copyWith(
                                    bottomRight: (widget.isMyMessage) ? .zero : null,
                                    bottomLeft: (!widget.isMyMessage && showAvatar) ? .zero : null,
                                  ),
                                )
                              : null,
                          child: Column(
                            crossAxisAlignment: .start,
                            mainAxisSize: .min,
                            children: [
                              Row(
                                crossAxisAlignment: widget.message.isCall ? .start : .end,
                                mainAxisSize: .min,
                                children: [
                                  widget.message.isCall
                                      ? MessageCallBody(
                                          message: widget.message,
                                        )
                                      : MessageBody(
                                          showSenderName: showSenderName,
                                          isSkeleton: widget.isSkeleton,
                                          message: widget.message,
                                          showTopic: widget.showTopic,
                                          isStarred: isStarred,
                                          maxMessageWidth: maxWidthMessage,
                                          onSelectedTextChanged: onSelectedTextChanged,
                                        ),
                                  if (widget.message.aggregatedReactions.isEmpty)
                                    Column(
                                      crossAxisAlignment: .end,
                                      children: [
                                        if (widget.message.isCall)
                                          IconButton(
                                            padding: .zero,
                                            onPressed: () => joinCall(context),
                                            icon: Assets.icons.call.svg(
                                              width: 32,
                                              height: 32,
                                              colorFilter: ColorFilter.mode(AppColors.green, .srcIn),
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
                                  mainAxisSize: .min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: maxWidthMessage),
                                      child: MessageReactionsList(
                                        message: widget.message,
                                        myUserId: widget.myUserId,
                                        maxWidth: maxWidthMessage,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        if (widget.message.isCall)
                                          IconButton(
                                            padding: .zero,
                                            onPressed: () => joinCall(context),
                                            icon: Assets.icons.call.svg(
                                              width: 32,
                                              height: 32,
                                              colorFilter: ColorFilter.mode(AppColors.green, .srcIn),
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
          ),
        );
      },
    );
  }
}
