import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatItem extends StatefulWidget {
  final ChatEntity chat;
  final VoidCallback onTap;
  const ChatItem({super.key, required this.chat, required this.onTap});

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  bool _isExpanded = false;

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeInOut;

  onTap() async {
    if (widget.chat.type == ChatType.channel) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
      await context.read<MessengerCubit>().getChannelTopics(widget.chat.streamId!);
      if (_isExpanded == false) {
        return;
      }
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final cardColors = Theme.of(context).extension<CardColors>()!;
    return Material(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
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
                  color: cardColors.base,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      UserAvatar(avatarUrl: widget.chat.avatarUrl, size: 30),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.chat.displayTitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColors.text100,
                              ),
                            ),
                            if (widget.chat.type == ChatType.channel)
                              Text(
                                widget.chat.lastMessageSenderName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                widget.chat.lastMessagePreview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: textColors.text50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          widget.chat.type == ChatType.channel
                              ? AnimatedRotation(
                                  duration: const Duration(milliseconds: 200),
                                  turns: _isExpanded ? 0.5 : 0.0,
                                  child: Assets.icons.arrowDown.svg(),
                                )
                              : Text(
                                  DateFormat('HH:mm').format(widget.chat.lastMessageDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: textColors.text50,
                                  ),
                                ),
                          UnreadBadge(
                            count: widget.chat.unreadCount,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                        return Container(
                          height: 76,
                          padding: EdgeInsetsGeometry.only(left: 38),
                          decoration: BoxDecoration(
                            color: cardColors.base,
                          ),
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "# ${topic.name}",
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontSize: 14,
                                      color: textColors.text100,
                                    ),
                                  ),
                                  Text(
                                    widget.chat.lastMessageSenderName!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      widget.chat.lastMessagePreview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: textColors.text50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
