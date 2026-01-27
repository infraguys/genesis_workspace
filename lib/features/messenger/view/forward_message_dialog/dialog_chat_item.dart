part of './forward_message_dialog.dart';

class _DialogChatItem extends StatefulWidget {
  const _DialogChatItem({super.key, required this.chat, required this.showTopics, required this.messageId, this.quote});

  final ChatEntity chat;
  final bool showTopics;
  final int messageId;
  final String? quote;

  @override
  State<_DialogChatItem> createState() => _DialogChatItemState();
}

class _DialogChatItemState extends State<_DialogChatItem> with OpenChatMixin {
  bool _isExpanded = false;

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeInOut;

  Set<int> get userIds => widget.chat.dmIds?.toSet() ?? {};
  int get chatId => widget.chat.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final cardColors = theme.extension<CardColors>()!;
    const materialBorderRadius = BorderRadius.all(.circular(8));
    double rightContainerHeight;

    switch (widget.chat.type) {
      case ChatType.channel:
        rightContainerHeight = 52;
      default:
        rightContainerHeight = 49;
    }

    return Material(
      borderRadius: materialBorderRadius,
      animationDuration: const Duration(milliseconds: 200),
      animateColor: true,
      color: cardColors.base,
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              if (widget.chat.type != .channel) {
                final chatCubit = context.read<ChatCubit>();
                final messagesCubit = context.read<MessagesCubit>();
                try {
                  final message = await messagesCubit.getMessageById(
                    messageId: widget.messageId,
                    applyMarkdown: false,
                  );
                  await chatCubit.sendMessage(
                    content: message.makeForwardedContent(
                      quote: widget.quote,
                    ),
                    chatIds: widget.chat.dmIds,
                  );
                  if (context.mounted) {
                    context.pop();
                    openChat(
                      context,
                      chatId: chatId,
                      membersIds: userIds,
                      replace: true,
                    );
                  }
                } on DioException catch (e) {
                  if (context.mounted) {
                    showErrorSnackBar(context, exception: e);
                  }
                }
              }
            },
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
                        color: cardColors.base,
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
                                            fontWeight: currentSize(context) <= ScreenSize.tablet
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                          ),
                                        ),
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
                                mainAxisAlignment: .spaceAround,
                                crossAxisAlignment: .end,
                                children: [
                                  Row(
                                    children: [
                                      if (widget.chat.isPinned) Assets.icons.pinned.svg(height: 20),
                                      (widget.chat.type == .channel)
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
                ],
              ),
            ),
          ),
          // if (currentSize(context) > ScreenSize.tablet)
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
                          return _DialogTopicItem(
                            chat: widget.chat,
                            topic: topic,
                            messageId: widget.messageId,
                            quote: widget.quote,
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
