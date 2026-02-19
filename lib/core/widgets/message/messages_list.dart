import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/unread_marker.dart';
import 'package:genesis_workspace/core/widgets/topic_separator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MessagesList extends StatefulWidget {
  final List<MessageEntity> messages;
  final ScrollController controller;
  final void Function(int id)? onRead;
  final Future<void> Function()? loadMorePrev;
  final Future<void> Function()? loadMoreNext;
  final VoidCallback? onReadAll;
  final bool showTopic;
  final bool isLoadingMore;
  final int myUserId;
  final void Function(int messageId, {String? quote})? onTapQuote;
  final void Function(UpdateMessageRequestEntity body)? onTapEditMessage;
  final bool isSelectMode;
  final List<MessageEntity> selectedMessages;
  final int? focusedMessageId;

  const MessagesList({
    super.key,
    required this.messages,
    required this.controller,
    this.onRead,
    this.loadMorePrev,
    this.loadMoreNext,
    this.showTopic = false,
    required this.isLoadingMore,
    required this.myUserId,
    this.onTapQuote,
    this.onTapEditMessage,
    this.onReadAll,
    this.isSelectMode = false,
    this.selectedMessages = const <MessageEntity>[],
    this.focusedMessageId,
  });

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  String? _currentDayLabel;
  bool _showDayLabel = false;
  bool _showScrollToBottom = false;
  Timer? _dayLabelTimer;
  int? _firstUnreadIndexInReversed;

  late final UserEntity? _myUser;
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;
  late final ScrollOffsetListener _scrollOffsetListener;
  StreamSubscription<double>? _scrollOffsetSubscription;

  bool showEmojiPicker = false;

  late List<MessageEntity> _reversed;
  bool _isLoadMoreInFlight = false;

  @override
  void initState() {
    super.initState();
    _reversed = widget.messages.reversed.toList(growable: false);

    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);
    _scrollOffsetListener = ScrollOffsetListener.create();
    _scrollOffsetSubscription = _scrollOffsetListener.changes.listen(_onScrollOffsetChanged);

    _myUser = context.read<ProfileCubit>().state.user;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstUnreadIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant MessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.messages, widget.messages)) {
      _reversed = widget.messages.reversed.toList(growable: false);
      // _scrollToFirstUnreadIfNeeded();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) BrowserContextMenu.enableContextMenu();
    _itemPositionsListener.itemPositions.removeListener(_onItemPositionsChanged);
    _scrollOffsetSubscription?.cancel();
    _dayLabelTimer?.cancel();
    super.dispose();
  }

  void _scrollToFirstUnreadIfNeeded() {
    final List<MessageEntity> reversedMessages = widget.messages.reversed.toList();

    _firstUnreadIndexInReversed = _findFirstUnreadBoundaryIndex(reversedMessages);

    if (_firstUnreadIndexInReversed != null) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(
          index: _firstUnreadIndexInReversed!,
        );
      }
    } else {
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: 0);
      }
    }
  }

  int? _findFirstUnreadBoundaryIndex(List<MessageEntity> reversedMessages) {
    for (int index = reversedMessages.length - 1; index >= 0; index--) {
      final MessageEntity message = reversedMessages[index];
      final bool isRead = message.flags?.contains('read') ?? false;
      final bool isOwnMessage = message.senderId == widget.myUserId;

      // Do not center the list around unread messages sent by the current user.
      if (!isRead && !isOwnMessage) {
        final MessageEntity? previous = (index + 1 < reversedMessages.length) ? reversedMessages[index + 1] : null;
        final bool previousIsRead = switch (previous) {
          null => true,
          _ when previous.senderId == widget.myUserId => true,
          _ => previous.flags?.contains('read') ?? false,
        };

        if (previousIsRead) {
          return index;
        }
      }
    }
    return null;
  }

  void _onItemPositionsChanged() {
    if (!mounted) {
      return;
    }
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty || _reversed.isEmpty) {
      return;
    }

    _updateScrollToBottom(positions);
  }

  void _onScrollOffsetChanged(double _) {
    if (!mounted) {
      return;
    }
    _handleScrollActivity();
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty || _reversed.isEmpty) {
      return;
    }
    _maybeLoadMore(positions);
  }

  void _handleScrollActivity() {
    if (!_showDayLabel) {
      setState(() => _showDayLabel = true);
    }
    _dayLabelTimer?.cancel();
    _dayLabelTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() => _showDayLabel = false);
    });
  }

  void _updateScrollToBottom(Iterable<ItemPosition> positions) {
    final isNearBottom = positions.any((position) => position.index == 0);
    final shouldShow = !isNearBottom;
    if (_showScrollToBottom != shouldShow) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  void _maybeLoadMore(Iterable<ItemPosition> positions) {
    if (_isLoadMoreInFlight || widget.isLoadingMore || widget.loadMorePrev == null) {
      return;
    }
    final lastIndex = _reversed.length - 1;
    final isTopVisible = positions.any((position) => position.index == lastIndex);
    if (isTopVisible) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_isLoadMoreInFlight || widget.loadMorePrev == null) {
      return;
    }
    _isLoadMoreInFlight = true;
    try {
      await widget.loadMorePrev!();
    } finally {
      if (mounted) {
        _isLoadMoreInFlight = false;
      }
    }
  }

  void _scrollToBottom() {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: 0,
        alignment: 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    if (widget.onReadAll != null) {
      widget.onReadAll!();
    }
  }

  int _dayInt(int tsSec) {
    final dt = DateTime.fromMillisecondsSinceEpoch(tsSec * 1000);
    return dt.year * 10000 + dt.month * 100 + dt.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isLoadingMore)
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: const LinearProgressIndicator(),
          ),
        Expanded(
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                child: ScrollablePositionedList.separated(
                  reverse: true,
                  itemCount: _reversed.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12, top: 12),
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  scrollOffsetListener: _scrollOffsetListener,
                  separatorBuilder: (BuildContext context, int index) {
                    final currentMessage = _reversed[index];
                    final nextMessage = _reversed[index + 1];

                    final messageDate = DateTime.fromMillisecondsSinceEpoch(currentMessage.timestamp * 1000);
                    final isNewDay = _dayInt(currentMessage.timestamp) != _dayInt(nextMessage.timestamp);
                    final unreadCount = _reversed.where((message) => message.isUnread).length;
                    //   final isNewUser = message.senderId != nextMessage.senderId;

                    final bool isNewTopic = currentMessage.subject != nextMessage.subject;

                    return Padding(
                      padding: (!isNewTopic && !isNewDay) ? const .symmetric(vertical: 4) : const .all(16.0),
                      child: Column(
                        mainAxisSize: .min,
                        spacing: 8.0,
                        children: [
                          if (_firstUnreadIndexInReversed != null && index == _firstUnreadIndexInReversed!)
                            UnreadMessagesMarker(unreadCount: unreadCount),
                          if (isNewTopic) TopicSeparator(message: currentMessage),
                          if (isNewDay) MessageDayLabel(label: _getDayLabel(context, messageDate)),
                        ],
                      ),
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final message = _reversed[index];
                    final MessageEntity? nextMessage = (_reversed.length > 1 && index != _reversed.length - 1)
                        ? _reversed[index + 1]
                        : null;
                    final MessageEntity? prevMessage = index != 0 ? _reversed[index - 1] : null;

                    final messageDate = DateTime.fromMillisecondsSinceEpoch(message.timestamp * 1000);
                    final isMyMessage = message.senderId == _myUser?.userId;

                    final isNewUser = message.senderId != nextMessage?.senderId;
                    final prevOtherUser = index != 0 && prevMessage?.senderId != message.senderId;
                    final isMessageMiddle =
                        message.senderId == nextMessage?.senderId && message.senderId == prevMessage?.senderId;
                    final isSingle = prevOtherUser && isNewUser;

                    MessageUIOrder messageOrder;
                    if (index == 0) {
                      messageOrder = isNewUser ? MessageUIOrder.lastSingle : MessageUIOrder.last;
                    } else if (isSingle) {
                      messageOrder = MessageUIOrder.single;
                    } else if (isNewUser) {
                      messageOrder = MessageUIOrder.first;
                    } else if (isMessageMiddle) {
                      messageOrder = MessageUIOrder.middle;
                    } else if (prevOtherUser) {
                      messageOrder = MessageUIOrder.last;
                    } else {
                      messageOrder = MessageUIOrder.middle;
                    }

                    bool isNewDay = false;

                    if (prevMessage != null) {
                      final prevMessageDate = DateTime.fromMillisecondsSinceEpoch(
                        prevMessage.timestamp * 1000,
                      );

                      isNewDay =
                          messageDate.day != prevMessageDate.day ||
                          messageDate.month != prevMessageDate.month ||
                          messageDate.year != prevMessageDate.year;
                    }

                    return VisibilityDetector(
                      key: ValueKey('msg-${message.id}'),
                      onVisibilityChanged: (info) {
                        final visiblePercentage = info.visibleFraction * 100;
                        if (visiblePercentage > 50) {
                          final label = _getDayLabel(context, messageDate);
                          if (_currentDayLabel != label) {
                            setState(() => _currentDayLabel = label);
                          }
                        }
                        if (visiblePercentage > 50 &&
                            (message.flags == null ||
                                message.flags!.isEmpty ||
                                (message.flags != null && !message.flags!.contains('read')))) {
                          widget.onRead?.call(message.id);
                        }
                      },
                      child: MessageItem(
                        isMyMessage: isMyMessage,
                        message: message,
                        messageOrder: messageOrder,
                        showTopic: widget.showTopic,
                        myUserId: widget.myUserId,
                        isNewDay: isNewDay,
                        onTapQuote: widget.onTapQuote ?? (_, {quote}) {},
                        onTapEditMessage: widget.onTapEditMessage ?? (_) {},
                        isSelectMode: widget.isSelectMode,
                        isSelected: widget.selectedMessages.any(
                          (selectedMessage) => selectedMessage.id == message.id,
                        ),
                        isFocused: widget.focusedMessageId == message.id,
                      ),
                    );
                  },
                ),
              ),
              // Лейбл даты при скролле
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _showDayLabel && _currentDayLabel != null ? 1.0 : 0.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        _currentDayLabel ?? '',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ),
              // Кнопка "Scroll to Bottom"
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showScrollToBottom ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_showScrollToBottom,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDayLabel(BuildContext context, DateTime date) {
    final today = DateTime.now();
    if (_isToday(date, today)) {
      return context.t.dateLabels.today;
    } else if (_isYesterday(date, today)) {
      return context.t.dateLabels.yesterday;
    } else {
      return DateFormat.yMMMMd(LocaleSettings.currentLocale.languageCode).format(date);
    }
  }

  bool _isToday(DateTime date, DateTime today) =>
      date.day == today.day && date.month == today.month && date.year == today.year;

  bool _isYesterday(DateTime date, DateTime today) {
    final y = today.subtract(const Duration(days: 1));
    return date.day == y.day && date.month == y.month && date.year == y.year;
  }
}

class MessageDayLabel extends StatelessWidget {
  final String label;

  const MessageDayLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: textColors.text100,
      ),
    );
  }
}
