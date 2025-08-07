import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/widgets/message_input.dart';
import 'package:genesis_workspace/core/widgets/message_item.dart';
import 'package:genesis_workspace/core/widgets/messages_list.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelChatView extends StatefulWidget {
  final ChannelChatExtra extra;

  const ChannelChatView({super.key, required this.extra});

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
      context.read<ChannelChatCubit>().loadMoreMessages(widget.extra.channel.name);
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
  void didChangeDependencies() {
    _myUser = context.read<ProfileCubit>().state.user!;
    context.read<ChannelChatCubit>().setChannel(widget.extra.channel);
    context.read<ChannelChatCubit>().setTopic(widget.extra.topicEntity);
    _future = context.read<ChannelChatCubit>().getChannelMessages(widget.extra.channel.name);
    _scrollController = ScrollController()..addListener(_onScroll);
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ChannelChatView oldWidget) {
    context.read<ChannelChatCubit>().setTopic(widget.extra.topicEntity);
    context.read<ChannelChatCubit>().getChannelMessages(
      widget.extra.channel.name,
      didUpdateWidget:
          (oldWidget.extra.topicEntity != widget.extra.topicEntity ||
          oldWidget.extra.channel != widget.extra.channel),
    );
    _messageController.clear();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    context.read<EmojiKeyboardCubit>().setShowEmojiKeyboard(false, closeKeyboard: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: parseColor(widget.extra.channel.color),
        centerTitle: currentSize(context) <= ScreenSize.lTablet,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.extra.channel.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.extra.topicEntity != null)
              Text(
                widget.extra.topicEntity!.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return const Center(child: Text("Some error..."));
          }

          return BlocBuilder<ChannelChatCubit, ChannelChatState>(
            builder: (context, state) {
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
                                    );
                                  },
                                ),
                              )
                            : MessagesList(
                                messages: state.messages,
                                controller: _scrollController,
                                showTopic: widget.extra.topicEntity == null,
                                isLoadingMore: state.isLoadingMore || state.isMessagesPending,
                                onRead: (id) {
                                  context.read<ChannelChatCubit>().scheduleMarkAsRead(id);
                                },
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
                                streamId: widget.extra.channel.streamId,
                                content: content,
                                topic: widget.extra.topicEntity?.name,
                              );
                            } catch (e) {}
                          }
                        : null,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
