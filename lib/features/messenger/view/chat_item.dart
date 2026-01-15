import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:genesis_workspace/features/messenger/view/topic_item.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
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

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeInOut;

  final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final cardColors = Theme.of(context).extension<CardColors>()!;
    const BorderRadius materialBorderRadius = BorderRadius.all(Radius.circular(8));
    double rightContainerHeight;

    switch (widget.chat.type) {
      case ChatType.channel:
        rightContainerHeight = 52;
        break;
      default:
        rightContainerHeight = 49;
        break;
    }
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
      child: CustomPopup(
        key: popupKey,
        backgroundColor: theme.colorScheme.surfaceDim,
        arrowColor: theme.colorScheme.surface,
        rootNavigator: true,
        isLongPress: currentSize(context) <= ScreenSize.tablet,
        contentDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(12),
          boxShadow: kElevationToShadow[3],
        ),
        content: Container(
          width: 240,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              TextButton(
                onPressed: () async {
                  context.pop();
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
                child: Text(context.t.folders.addToFolder),
              ),
              TextButton(
                onPressed: () async {
                  onTogglePin();
                  context.pop();
                },
                child: Text(widget.chat.isPinned ? context.t.chat.unpinChat : context.t.chat.pinChat),
              ),
              if (widget.chat.type == ChatType.channel) ...[
                TextButton(
                  child: Text(
                    widget.chat.isMuted ? context.t.channel.unmuteChannel : context.t.channel.muteChannel,
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    context.pop();
                    if (widget.chat.isMuted) {
                      await context.read<MessengerCubit>().unmuteChannel(widget.chat);
                    } else {
                      await context.read<MessengerCubit>().muteChannel(widget.chat);
                    }
                  },
                ),
              ],
              TextButton(
                child: Text(
                  context.t.readAllMessages,
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  context.pop();
                  await context.read<MessengerCubit>().readAllMessages(
                    widget.chat.id,
                  );
                },
              ),
            ],
          ),
        ),
        child: Material(
          borderRadius: materialBorderRadius,
          animationDuration: const Duration(milliseconds: 200),
          animateColor: true,
          color: widget.showTopics ? Colors.transparent : cardColors.base,
          child: Column(
            children: [
              InkWell(
                onTap: onTap,
                onSecondaryTap: () => popupKey.currentState?.show(),
                borderRadius: BorderRadius.circular(8),
                overlayColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered) ? cardColors.active : null,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 65,
                  ),
                  child: Stack(
                    alignment: AlignmentGeometry.centerLeft,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 65,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8).copyWith(
                              bottomLeft: _isExpanded ? Radius.zero : Radius.circular(8),
                              bottomRight: _isExpanded ? Radius.zero : Radius.circular(8),
                            ),
                            color: isSelected ? cardColors.active : cardColors.base,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                UserAvatar(
                                  avatarUrl: widget.chat.avatarUrl,
                                  size: currentSize(context) <= ScreenSize.tablet ? 40 : 30,
                                  backgroundColor: widget.chat.backgroundColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        spacing: 4,
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 185,
                                            ),
                                            child: Text(
                                              widget.chat.displayTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: textColors.text100,
                                                fontWeight: currentSize(context) <= ScreenSize.tablet
                                                    ? FontWeight.w500
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          if (_isPinPending)
                                            CupertinoActivityIndicator(
                                              radius: 6,
                                            ),
                                          if (widget.chat.isMuted)
                                            Icon(
                                              Icons.headset_off,
                                              size: 14,
                                              color: AppColors.noticeDisabled,
                                            ),
                                        ],
                                      ),
                                      if (widget.chat.type == ChatType.channel)
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
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          if (widget.chat.isPinned) Assets.icons.pinned.svg(height: 20),
                                          (widget.chat.type == ChatType.channel &&
                                                  currentSize(context) > ScreenSize.tablet)
                                              ? InkWell(
                                                  borderRadius: BorderRadius.circular(35),
                                                  onTap: () {
                                                    setState(() {
                                                      _isExpanded = !_isExpanded;
                                                    });
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
                                                    padding: EdgeInsets.symmetric(vertical: 6),
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
                            alignment: Alignment.centerLeft,
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
              if (currentSize(context) > ScreenSize.tablet)
                AnimatedSize(
                  duration: _animationDuration,
                  curve: _animationCurve,
                  child: _isExpanded
                      ? Skeletonizer(
                          enabled: widget.chat.isTopicsLoading,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.chat.isTopicsLoading ? 4 : widget.chat.topics!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final topic = widget.chat.topics?[index] ?? TopicEntity.fake();
                              return TopicItem(chat: widget.chat, topic: topic);
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
