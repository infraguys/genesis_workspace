import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelChatView extends StatefulWidget {
  final int channelId;
  final String? topicName;
  final int? unreadMessagesCount;

  const ChannelChatView({
    super.key,
    required this.channelId,
    this.topicName,
    this.unreadMessagesCount = 0,
  });

  @override
  State<ChannelChatView> createState() => _ChannelChatViewState();
}

class _ChannelChatViewState extends State<ChannelChatView> {
  late final Future _future;
  late final UserEntity _myUser;
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;

  String _currentText = '';

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !context.read<ChannelChatCubit>().state.isLoadingMore) {
      context.read<ChannelChatCubit>().loadMoreMessages();
    }
  }

  Future<void> _onTextChanged() async {
    setState(() {
      _currentText = _messageController.text;
    });
    await context.read<ChannelChatCubit>().changeTyping(
      op: _currentText.isEmpty ? TypingEventOp.stop : TypingEventOp.start,
    );
  }

  @override
  void initState() {
    _myUser = context.read<ProfileCubit>().state.user!;
    _future = context.read<ChannelChatCubit>().getInitialData(
      streamId: widget.channelId,
      topicName: widget.topicName,
      unreadMessagesCount: widget.unreadMessagesCount,
    );
    _scrollController = ScrollController()..addListener(_onScroll);
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(ChannelChatView oldWidget) {
    if (widget.channelId != oldWidget.channelId) {
      context.read<ChannelChatCubit>().getInitialData(
        streamId: widget.channelId,
        topicName: widget.topicName,
        didUpdateWidget:
            (oldWidget.topicName != widget.topicName || oldWidget.channelId != widget.channelId),
      );
    } else if (widget.topicName != oldWidget.topicName) {
      context
          .read<ChannelChatCubit>()
          .getChannelTopics(streamId: widget.channelId, topicName: widget.topicName)
          .then((_) {
            context.read<ChannelChatCubit>().getChannelMessages(
              unreadMessagesCount: widget.unreadMessagesCount,
            );
          });
    }

    _messageController.clear();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelChatCubit, ChannelChatState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            // backgroundColor: parseColor(state.channel.color),
            centerTitle: false,
            title: Skeletonizer(
              enabled: state.channel == null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.channel?.name ?? 'Channel Name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.topicName != null)
                    Text(
                      widget.topicName!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                ],
              ),
            ),
          ),
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                return const Center(child: Text("Some error..."));
              }
              return Column(
                children: [
                  if (state.messages.isEmpty && snapshot.connectionState == ConnectionState.done)
                    Expanded(child: Center(child: Text(context.t.noMessagesHereYet)))
                  else
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (currentSize(context) < ScreenSize.lTablet) {
                            FocusScope.of(context).unfocus();
                            context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(
                              false,
                              closeKeyboard: true,
                            );
                          }
                        },
                        child:
                            (snapshot.connectionState == ConnectionState.waiting ||
                                state.isMessagesPending)
                            ? Skeletonizer(
                                enabled: true,
                                child: ListView.separated(
                                  itemCount: 20,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ).copyWith(bottom: 12),
                                  itemBuilder: (context, index) {
                                    return MessageItem(
                                      isMyMessage: index % 5 == 0,
                                      message: MessageEntity.fake(),
                                      isSkeleton: true,
                                      messageOrder: MessageUIOrder.single,
                                      myUserId: _myUser.userId,
                                    );
                                  },
                                ),
                              )
                            : MessagesList(
                                messages: state.messages,
                                controller: _scrollController,
                                showTopic: state.topic == null,
                                isLoadingMore: state.isLoadingMore || state.isMessagesPending,
                                onRead: (id) {
                                  context.read<ChannelChatCubit>().scheduleMarkAsRead(id);
                                },
                                loadMore: context.read<ChannelChatCubit>().loadMoreMessages,
                                myUserId: _myUser.userId,
                              ),
                      ),
                    ),
                  MessageInput(
                    controller: _messageController,
                    isMessagePending: state.isMessagePending,
                    onSend: _currentText.isNotEmpty
                        ? () async {
                            final content = _messageController.text;
                            _messageController.clear();
                            try {
                              await context.read<ChannelChatCubit>().sendMessage(
                                streamId: state.channel!.streamId,
                                content: content,
                                topic: state.topic?.name,
                              );
                            } catch (e) {}
                          }
                        : null,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
