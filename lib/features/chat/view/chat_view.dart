import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/chat/view/message_input.dart';
import 'package:genesis_workspace/features/home/view/user_avatar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';

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

  void _scrollToBottom() {
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = context.read<ChatCubit>().getMessages(widget.userEntity.userId);
    _controller = ScrollController();
    _messageController = TextEditingController();
    _myUser = context.read<ProfileCubit>().state.user!;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userEntity.fullName),
                Text("typing...", style: TextStyle(fontSize: 11)),
              ],
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
              return AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: _controller,
                        itemCount: state.messages.length,
                        padding: EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: 12);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final MessageEntity message = state.messages[index];
                          final bool isMyMessage = message.senderId == _myUser.userId;
                          return Align(
                            alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Row(
                                spacing: 8,
                                mainAxisAlignment: isMyMessage
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  !isMyMessage
                                      ? UserAvatar(avatarUrl: message.avatarUrl)
                                      : SizedBox(),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isMyMessage
                                          ? theme.colorScheme.secondaryContainer.withAlpha(128)
                                          : theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.senderFullName,
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        Text(message.content),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Divider(),
                    MessageInput(
                      controller: _messageController,
                      onSend: _messageController.text.isNotEmpty
                          ? () async {
                              await context.read<ChatCubit>().sendMessage(
                                chatId: widget.userEntity.userId,
                                content: _messageController.text,
                              );
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
