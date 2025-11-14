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
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatItem extends StatefulWidget {
  final ChatEntity chat;
  final VoidCallback onTap;
  final bool showTopics;

  const ChatItem({super.key, required this.chat, required this.onTap, required this.showTopics});

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  bool _isExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final cardColors = Theme.of(context).extension<CardColors>()!;
    double rightContainerHeight;

    switch (widget.chat.type) {
      case ChatType.channel:
        rightContainerHeight = 52;
        break;
      default:
        rightContainerHeight = 49;
        break;
    }
    return CustomPopup(
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
                // await context.read<MessengerCubit>().loadFolders();
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
                if (widget.chat.isPinned) {
                  await context.read<MessengerCubit>().unpinChat(widget.chat.id);
                } else {
                  await context.read<MessengerCubit>().pinChat(chatId: widget.chat.id);
                }
                if (mounted) {
                  context.pop();
                }
              },
              child: Text(widget.chat.isPinned ? context.t.chat.unpinChat : context.t.chat.pinChat),
            ),
          ],
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(8),
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
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8).copyWith(
                      bottomLeft: _isExpanded ? Radius.zero : Radius.circular(8),
                      bottomRight: _isExpanded ? Radius.zero : Radius.circular(8),
                    ),
                    color: widget.showTopics ? Colors.transparent : cardColors.base,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserAvatar(
                          avatarUrl: widget.chat.avatarUrl,
                          size: currentSize(context) <= ScreenSize.tablet ? 40 : 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
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
                            // spacing: 10,
                            children: [
                              Row(
                                children: [
                                  if (widget.chat.isPinned) Assets.icons.pinned.svg(height: 20),
                                  widget.chat.type == ChatType.channel
                                      ? AnimatedRotation(
                                          duration: const Duration(milliseconds: 200),
                                          turns: _isExpanded ? 0.5 : 0.0,
                                          child: Assets.icons.arrowDown.svg(),
                                        )
                                      : SizedBox(
                                          height: 20,
                                          child: Text(
                                            DateFormat('HH:mm').format(widget.chat.lastMessageDate),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: textColors.text50,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              UnreadBadge(count: widget.chat.unreadMessages.length),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            return InkWell(
                              onTap: () {
                                context.read<MessengerCubit>().selectChat(
                                  widget.chat,
                                  selectedTopic: topic.name,
                                );
                              },
                              child: Container(
                                height: 76,
                                padding: EdgeInsetsGeometry.only(left: 38, right: 8, bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColors.base,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 3,
                                            height: 47,
                                            decoration: BoxDecoration(
                                              color: Colors.yellow,
                                              borderRadius: BorderRadiusGeometry.circular(4),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message: topic.name,
                                                  child: Text(
                                                    "# ${topic.name}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.labelMedium?.copyWith(
                                                      fontSize: 14,
                                                      color: textColors.text100,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  topic.lastMessageSenderName,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                                MessagePreview(
                                                  messagePreview: topic.lastMessagePreview,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Skeleton.ignore(
                                      child: SizedBox(
                                        height: 21,
                                        child: UnreadBadge(count: topic.unreadMessages.length),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
