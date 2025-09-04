import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/unread_marker.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../i18n/generated/strings.g.dart';

typedef ContextMenuBuilder = Widget Function(BuildContext context, Offset offset);

class MessagesList extends StatefulWidget {
  final List<MessageEntity> messages;
  final ScrollController controller;
  final void Function(int id)? onRead;
  final void Function()? loadMore;
  final bool showTopic;
  final bool isLoadingMore;
  final int myUserId;
  final void Function(int messageId)? onTapQuote;

  const MessagesList({
    super.key,
    required this.messages,
    required this.controller,
    this.onRead,
    this.loadMore,
    this.showTopic = false,
    required this.isLoadingMore,
    required this.myUserId,
    this.onTapQuote,
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
  late final AutoScrollController _autoScrollController;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) BrowserContextMenu.disableContextMenu();

    _autoScrollController = AutoScrollController(axis: Axis.vertical);

    _autoScrollController.addListener(_onScroll);

    _myUser = context.read<ProfileCubit>().state.user;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstUnreadIfNeeded();
    });
  }

  @override
  void dispose() {
    if (kIsWeb) BrowserContextMenu.enableContextMenu();
    _autoScrollController.removeListener(_onScroll);
    _dayLabelTimer?.cancel();
    super.dispose();
  }

  void _scrollToFirstUnreadIfNeeded() {
    final List<MessageEntity> reversedMessages = widget.messages.reversed.toList();

    _firstUnreadIndexInReversed = _findFirstUnreadBoundaryIndex(reversedMessages);

    if (_firstUnreadIndexInReversed != null) {
      _autoScrollController.scrollToIndex(
        _firstUnreadIndexInReversed!,
        preferPosition: AutoScrollPosition.end, // начало экрана
        duration: const Duration(milliseconds: 300),
      );
    } else {
      _autoScrollController.jumpTo(0);
    }
  }

  int? _findFirstUnreadBoundaryIndex(List<MessageEntity> reversedMessages) {
    for (int index = reversedMessages.length - 1; index >= 0; index--) {
      final MessageEntity message = reversedMessages[index];
      final bool isRead = message.flags?.contains('read') ?? false;

      if (!isRead) {
        final MessageEntity? previous = (index + 1 < reversedMessages.length)
            ? reversedMessages[index + 1]
            : null;
        final bool previousIsRead = previous == null
            ? true
            : (previous.flags?.contains('read') ?? false);

        if (previousIsRead) {
          return index;
        }
      }
    }
    return null;
  }

  void _onScroll() {
    if (_autoScrollController.offset >= _autoScrollController.position.maxScrollExtent &&
        !widget.isLoadingMore) {
      if (widget.loadMore != null) {
        widget.loadMore!();
      }
    }
    if (!_showDayLabel) {
      setState(() => _showDayLabel = true);
    }
    _dayLabelTimer?.cancel();
    _dayLabelTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _showDayLabel = false);
    });

    final showScrollToBottomOffset = 200.0;
    final isNearBottom =
        _autoScrollController.offset <=
        _autoScrollController.position.minScrollExtent + showScrollToBottomOffset;

    if (_showScrollToBottom == isNearBottom) {
      setState(() {
        _showScrollToBottom = !isNearBottom;
      });
    }
  }

  void _scrollToBottom() {
    _autoScrollController.animateTo(
      _autoScrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversedMessages = widget.messages.reversed.toList();
    final theme = Theme.of(context);

    return Column(
      children: [
        if (widget.isLoadingMore) const LinearProgressIndicator(),
        Expanded(
          child: Stack(
            children: [
              ListView.separated(
                controller: _autoScrollController,
                reverse: true,
                itemCount: reversedMessages.length,
                padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12, top: 12),
                separatorBuilder: (BuildContext context, int index) {
                  final message = reversedMessages[index];
                  final nextMessage = reversedMessages[index + 1];

                  final messageDate = DateTime.fromMillisecondsSinceEpoch(message.timestamp * 1000);
                  final nextMessageDate = DateTime.fromMillisecondsSinceEpoch(
                    nextMessage.timestamp * 1000,
                  );

                  final isNewDay =
                      messageDate.day != nextMessageDate.day ||
                      messageDate.month != nextMessageDate.month ||
                      messageDate.year != nextMessageDate.year;

                  if (_firstUnreadIndexInReversed != null &&
                      index == _firstUnreadIndexInReversed!) {
                    return UnreadMessagesMarker(
                      unreadCount: reversedMessages
                          .where((message) => message.hasUnreadMessages)
                          .length,
                    );
                  }

                  if (isNewDay) {
                    return MessageDayLabel(label: _getDayLabel(context, messageDate));
                  }
                  final isNewUser = message.senderId != nextMessage.senderId;
                  return SizedBox(height: isNewUser ? 12 : 2);
                },
                itemBuilder: (BuildContext context, int index) {
                  final message = reversedMessages[index];
                  final MessageEntity? nextMessage =
                      (reversedMessages.length > 1 && index != reversedMessages.length - 1)
                      ? reversedMessages[index + 1]
                      : null;
                  final MessageEntity? prevMessage = index != 0
                      ? reversedMessages[index - 1]
                      : null;

                  final messageDate = DateTime.fromMillisecondsSinceEpoch(message.timestamp * 1000);
                  final isMyMessage = message.senderId == _myUser?.userId;

                  final isNewUser = message.senderId != nextMessage?.senderId;
                  final prevOtherUser = index != 0 && prevMessage?.senderId != message.senderId;
                  final isMessageMiddle =
                      message.senderId == nextMessage?.senderId &&
                      message.senderId == prevMessage?.senderId;
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
                  return AutoScrollTag(
                    index: index,
                    key: ValueKey(index),
                    controller: _autoScrollController,
                    child: VisibilityDetector(
                      key: UniqueKey(),
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
                        onTapQuote: widget.onTapQuote ?? (_) {},
                      ),
                    ),
                  );
                },
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(label, style: Theme.of(context).textTheme.labelMedium)],
      ),
    );
  }
}
