import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/animated_overlay.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/messenger/bloc/create_chat/create_chat_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/mute/mute_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/create_chat/create_topic_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:genesis_workspace/features/messenger/view/topic_item.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatItem extends StatefulWidget {
  final ChatEntity chat;
  final VoidCallback onTap;
  final bool showTopics;
  final int? selectedChatId;

  const ChatItem({
    super.key,
    required this.chat,
    required this.onTap,
    required this.showTopics,
    this.selectedChatId,
  });

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  bool _isExpanded = false;
  bool _isPinPending = false;
  bool _showAllTopics = false;

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeInOut;
  static const double _menuPadding = 8.0;
  static const double _menuItemHeight = 36.0;
  static const double _menuItemSpacing = 4.0;

  static OverlayEntry? _menuEntry;

  void _closeOverlay() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _openContextMenu(Offset globalPosition) {
    _closeOverlay();

    if (!mounted) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }

    final localInOverlay = overlayBox.globalToLocal(globalPosition);
    final screenSize = MediaQuery.sizeOf(context);

    final double menuWidth = 270;
    const itemHeight = _menuItemHeight;
    const itemSpacing = _menuItemSpacing;
    const verticalPadding = _menuPadding;

    final itemsCount = 3 + (widget.chat.type == ChatType.channel ? 1 : 0);
    final estimatedHeight = (itemsCount * itemHeight) + (itemSpacing * (itemsCount - 1)) + (verticalPadding * 2);
    final openDown = (screenSize.height - localInOverlay.dy - _menuPadding) > estimatedHeight;

    final left = localInOverlay.dx.clamp(_menuPadding, screenSize.width - menuWidth - _menuPadding);

    _menuEntry = OverlayEntry(
      builder: (context) {
        return AnimatedOverlay(
          left: left,
          top: openDown ? localInOverlay.dy : null,
          bottom: openDown ? null : (screenSize.height - localInOverlay.dy),
          alignment: openDown ? Alignment.topLeft : Alignment.bottomLeft,
          closeOverlay: _closeOverlay,
          child: _ChatContextMenu(
            width: menuWidth,
            chat: widget.chat,
            onAddToFolder: () async {
              _closeOverlay();
              await showDialog(
                context: context,
                builder: (_) => SelectFoldersDialog(
                  onSave: (selectedFolderIds) async {
                    await context.read<MessengerCubit>().setFoldersForChat(
                      selectedFolderIds,
                      widget.chat.id,
                    );
                  },
                  folders: context.read<MessengerCubit>().state.folders,
                  loadSelectedFolderIds: () => context.read<MessengerCubit>().getFolderIdsForChat(
                    widget.chat.id,
                  ),
                ),
              );
            },
            onTogglePin: () async {
              _closeOverlay();
              await onTogglePin();
            },
            onToggleMute: widget.chat.type == ChatType.channel
                ? () async {
                    try {
                      _closeOverlay();
                      if (widget.chat.isMuted) {
                        await context.read<MuteCubit>().unmuteChannel(widget.chat);
                      } else {
                        await context.read<MuteCubit>().muteChannel(widget.chat);
                      }
                    } on DioException catch (e) {
                      showErrorSnackBar(context, exception: e);
                    }
                  }
                : null,
            onReadAll: () async {
              _closeOverlay();
              await context.read<MessengerCubit>().readAllMessages(widget.chat.id);
            },
            onCreateTopic: () async {
              _closeOverlay();
              await showDialog(
                context: context,
                builder: (_) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => getIt<CreateChatCubit>()),
                    ],
                    child: CreateTopicDialog(channelId: widget.chat.streamId),
                  );
                },
              );
            },
          ),
        );
      },
    );

    overlay.insert(_menuEntry!);
  }

  onTap() async {
    if (widget.chat.type == ChatType.channel) {
      if (mounted && currentSize(context) > ScreenSize.tablet) {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (_isExpanded == false) {
          return;
        }
        await context.read<MessengerCubit>().getChannelTopics(widget.chat.streamId!);
      } else {
        context.read<MessengerCubit>().loadTopics(widget.chat.streamId!);
      }
    }
    widget.onTap();
  }

  onTogglePin() async {
    setState(() => _isPinPending = true);
    try {
      if (widget.chat.isPinned) {
        await context.read<MessengerCubit>().unpinChat(widget.chat.id);
      } else {
        await context.read<MessengerCubit>().pinChat(chatId: widget.chat.id);
      }
    } finally {
      setState(() => _isPinPending = false);
    }
  }

  List<TopicEntity> get sortedTopics {
    final topics = widget.chat.topics ?? const [];
    return List<TopicEntity>.of(topics)..sort((a, b) => b.maxId.compareTo(a.maxId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final cardColors = theme.extension<CardColors>()!;

    final rightContainerHeight = switch (widget.chat.type) {
      ChatType.channel => 52.0,
      _ => 49.0,
    };

    final bool shouldShowLeftBorder = widget.showTopics && widget.chat.id == widget.selectedChatId;
    final bool isSelected = widget.chat.id == widget.selectedChatId;

    return BlocListener<MessengerCubit, MessengerState>(
      listenWhen: (previous, current) {
        return previous.selectedChat != null;
      },
      listener: (context, state) {
        if (state.selectedChat == null) {
          _isExpanded = false;
        }
      },
      child: Material(
        borderRadius: .all(.circular(8)),
        animationDuration: const Duration(milliseconds: 200),
        animateColor: true,
        color: widget.showTopics ? Colors.transparent : cardColors.base,
        child: Column(
          children: [
            Listener(
              behavior: .deferToChild,
              onPointerDown: (event) {
                if (event.kind == .mouse && event.buttons == kSecondaryMouseButton) {
                  _openContextMenu(event.position);
                }
              },
              child: GestureDetector(
                onLongPressStart: (details) {
                  if (platformInfo.isMobile) {
                    _openContextMenu(details.globalPosition);
                  }
                },
                child: InkWell(
                  onTap: onTap,
                  borderRadius: .circular(8),
                  overlayColor: .resolveWith(
                    (states) => states.contains(WidgetState.hovered) ? cardColors.active : null,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 65),
                    child: Stack(
                      alignment: .centerLeft,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 65),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: isSelected ? cardColors.active : cardColors.base,
                              borderRadius: BorderRadius.circular(8).copyWith(
                                bottomLeft: _isExpanded ? .zero : .circular(8),
                                bottomRight: _isExpanded ? .zero : .circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: const .symmetric(horizontal: 8),
                              child: Row(
                                crossAxisAlignment: .center,
                                children: [
                                  UserAvatar(
                                    avatarUrl: widget.chat.avatarUrl,
                                    size: currentSize(context) <= .tablet ? 40 : 30,
                                    backgroundColor: widget.chat.backgroundColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: .min,
                                      crossAxisAlignment: .start,
                                      children: [
                                        Row(
                                          spacing: 4,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 185),
                                              child: Text(
                                                widget.chat.displayTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: textColors.text100,
                                                  fontWeight: currentSize(context) <= .tablet ? .w500 : .w400,
                                                ),
                                              ),
                                            ),
                                            if (_isPinPending) CupertinoActivityIndicator(radius: 6),
                                            if (widget.chat.isMuted)
                                              Icon(
                                                Icons.headset_off,
                                                size: 14,
                                                color: AppColors.noticeDisabled,
                                              ),
                                          ],
                                        ),
                                        if (widget.chat.type == .channel)
                                          Text(
                                            widget.chat.lastMessageSenderName!,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        MessagePreview(messagePreview: widget.chat.lastMessagePreview),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: rightContainerHeight,
                                    child: Column(
                                      mainAxisAlignment: .spaceAround,
                                      crossAxisAlignment: .end,
                                      children: [
                                        Row(
                                          children: [
                                            if (widget.chat.isPinned) Assets.icons.pinned.svg(height: 20),
                                            (widget.chat.type == .channel && currentSize(context) > .tablet)
                                                ? InkWell(
                                                    borderRadius: .circular(35),
                                                    onTap: () {
                                                      setState(() => _isExpanded = !_isExpanded);
                                                      if (_isExpanded && (widget.chat.topics?.isEmpty ?? true)) {
                                                        unawaited(
                                                          context.read<MessengerCubit>().getChannelTopics(
                                                            widget.chat.streamId!,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 35,
                                                      height: 20,
                                                      padding: .symmetric(vertical: 6),
                                                      child: AnimatedRotation(
                                                        duration: const Duration(milliseconds: 200),
                                                        turns: _isExpanded ? 0.5 : 0.0,
                                                        child: Assets.icons.arrowDown.svg(height: 8),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 20,
                                                    width: 35,
                                                    child: Text(
                                                      DateFormat('HH:mm').format(widget.chat.lastMessageDate),
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: textColors.text50,
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        UnreadBadge(
                                          count: widget.chat.unreadMessages.length,
                                          isMuted: widget.chat.isMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (shouldShowLeftBorder)
                          IgnorePointer(
                            child: Align(
                              alignment: .centerLeft,
                              child: Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (currentSize(context) > .tablet)
              AnimatedSize(
                duration: _animationDuration,
                curve: _animationCurve,
                child: _isExpanded
                    ? Skeletonizer(
                        enabled: widget.chat.isTopicsLoading,
                        child: Builder(
                          builder: (context) {
                            final int topicsCount = sortedTopics.length;
                            final bool isLoading = widget.chat.isTopicsLoading;
                            final bool hasMoreThanLimit = topicsCount > 10;
                            final int visibleCount = hasMoreThanLimit && !_showAllTopics ? 10 : topicsCount;
                            final int listCount = isLoading ? 4 : visibleCount + (hasMoreThanLimit ? 1 : 0);

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listCount,
                              itemBuilder: (BuildContext context, int index) {
                                if (!isLoading && hasMoreThanLimit && index == listCount - 1) {
                                  return Padding(
                                    padding: const .symmetric(horizontal: 12, vertical: 8),
                                    child: SizedBox(
                                      width: .infinity,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: .circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() => _showAllTopics = !_showAllTopics);
                                        },
                                        child: Text(_showAllTopics ? context.t.showLess : context.t.showMore),
                                      ),
                                    ),
                                  );
                                }
                                final topic = isLoading ? TopicEntity.fake(index: index) : sortedTopics[index];
                                return TopicItem(chat: widget.chat, topic: topic);
                              },
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatContextMenu extends StatelessWidget {
  const _ChatContextMenu({
    required this.chat,
    required this.width,
    required this.onAddToFolder,
    required this.onTogglePin,
    required this.onReadAll,
    required this.onCreateTopic,
    this.onToggleMute,
  });

  final ChatEntity chat;
  final double width;
  final VoidCallback onAddToFolder;
  final VoidCallback onTogglePin;
  final VoidCallback? onToggleMute;
  final VoidCallback onReadAll;
  final VoidCallback onCreateTopic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const textColor = Colors.white;
    const iconColor = ColorFilter.mode(Colors.white, BlendMode.srcIn);

    return Container(
      width: width,
      padding: const .symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: .circular(8),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          _ChatContextMenuAction(
            textColor: textColor,
            icon: Assets.icons.folder,
            iconColor: iconColor,
            label: context.t.folders.addToFolder,
            onTap: onAddToFolder,
          ),
          _ChatContextMenuAction(
            textColor: textColor,
            icon: Assets.icons.pinned,
            iconColor: iconColor,
            label: chat.isPinned ? context.t.chat.unpinChat : context.t.chat.pinChat,
            onTap: onTogglePin,
          ),
          if (onToggleMute != null) ...[
            _ChatContextMenuAction(
              textColor: textColor,
              icon: chat.isMuted ? Assets.icons.volumeUp : Assets.icons.notif,
              iconColor: iconColor,
              label: chat.isMuted ? context.t.channel.unmuteChannel : context.t.channel.muteChannel,
              onTap: onToggleMute,
            ),
          ],
          _ChatContextMenuAction(
            textColor: textColor,
            icon: Assets.icons.readReceipt,
            iconColor: iconColor,
            label: context.t.readAllMessages,
            onTap: onReadAll,
          ),
          _ChatContextMenuAction(
            textColor: textColor,
            icon: Assets.icons.allChats,
            iconColor: iconColor,
            label: context.t.topic.createTopic,
            onTap: onCreateTopic,
          ),
        ],
      ),
    );
  }
}

class _ChatContextMenuAction extends StatelessWidget {
  const _ChatContextMenuAction({
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final Color textColor;
  final SvgGenImage icon;
  final ColorFilter iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    const iconSize = 20.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36.0),
      child: Material(
        child: InkWell(
          borderRadius: .circular(8),
          onTap: onTap,
          child: Padding(
            padding: const .symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              spacing: 12.0,
              children: [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: icon.svg(
                    width: iconSize,
                    height: iconSize,
                    colorFilter: iconColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: .w500, color: textColor),
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
