import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/home/view/user_avatar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';

class ChatView extends StatefulWidget {
  final UserEntity userEntity;

  const ChatView({super.key, required this.userEntity});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;

  void _scrollToBottom() {
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  @override
  void initState() {
    _future = context.read<ChatCubit>().getMessages(widget.userEntity.userId);
    _controller = ScrollController();
    _myUser = context.read<ProfileCubit>().state.user!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 8,
          children: [
            UserAvatar(avatarUrl: widget.userEntity.avatarUrl),
            Text(widget.userEntity.fullName),
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
              return ListView.separated(
                controller: _controller,
                itemCount: state.messages.length,
                padding: EdgeInsets.symmetric(horizontal: 12),
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
                          !isMyMessage ? UserAvatar(avatarUrl: message.avatarUrl) : SizedBox(),
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
                                Text(message.senderFullName, style: theme.textTheme.labelSmall),
                                Text(message.content),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
