import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/chat/view/message_input.dart';
import 'package:genesis_workspace/features/chat/view/message_item.dart';
import 'package:genesis_workspace/features/home/view/user_avatar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatView extends StatefulWidget {
  final UserEntity userEntity;

  const ChatView({super.key, required this.userEntity});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;
  late final TextEditingController _messageController;

  String _currentText = '';

  void _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !context.read<ChatCubit>().state.isLoadingMore) {
      context.read<ChatCubit>().loadMoreMessages();
    }
  }

  Future<void> _onTextChanged() async {
    setState(() {
      _currentText = _messageController.text;
    });
    await context.read<ChatCubit>().changeTyping(
      chatId: widget.userEntity.userId,
      op: _currentText.isEmpty ? TypingEventOp.stop : TypingEventOp.start,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _myUser = context.read<ProfileCubit>().state.user!;

    _future = context.read<ChatCubit>().getMessages(
      chatId: widget.userEntity.userId,
      myUserId: _myUser.userId,
    );
    _controller = ScrollController()..addListener(_onScroll);
    _messageController = TextEditingController();

    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          spacing: 8,
          children: [
            UserAvatar(avatarUrl: widget.userEntity.avatarUrl),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.userEntity.fullName),
                    Text(
                      state.typingId == widget.userEntity.userId ? "typing..." : "Online",
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error"));
            }
          }
          return BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: state.messages.isEmpty
                            ? Center(child: Text("No messages here yet..."))
                            : Column(
                                children: [
                                  if (state.isLoadingMore) const LinearProgressIndicator(),
                                  Expanded(
                                    child: ListView.separated(
                                      controller: _controller,
                                      reverse: true,
                                      itemCount: state.messages.length,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ).copyWith(bottom: 12),
                                      separatorBuilder: (BuildContext context, int index) {
                                        return SizedBox(height: 12);
                                      },
                                      itemBuilder: (BuildContext context, int index) {
                                        final message = state.messages.reversed.toList()[index];
                                        final isMyMessage = message.senderId == _myUser.userId;

                                        return VisibilityDetector(
                                          key: Key('message-${message.id}'),
                                          onVisibilityChanged: (info) {
                                            final visiblePercentage = info.visibleFraction * 100;

                                            if (visiblePercentage > 50 &&
                                                (message.flags == null || message.flags!.isEmpty)) {
                                              context.read<ChatCubit>().scheduleMarkAsRead(
                                                message.id,
                                              );
                                            }
                                          },
                                          child: MessageItem(
                                            isMyMessage: isMyMessage,
                                            message: message,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                                await context.read<ChatCubit>().sendMessage(
                                  chatId: widget.userEntity.userId,
                                  content: content,
                                );
                              } catch (e) {}
                            }
                          : null,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
