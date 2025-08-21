import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatView extends StatefulWidget {
  final int userId;

  const ChatView({super.key, required this.userId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;
  late final TextEditingController _messageController;

  String _currentText = '';

  Future<void> _onTextChanged() async {
    setState(() {
      _currentText = _messageController.text;
    });
    await context.read<ChatCubit>().changeTyping(
      op: _currentText.isEmpty ? TypingEventOp.stop : TypingEventOp.start,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _myUser = context.read<ProfileCubit>().state.user!;

    _future = context.read<ChatCubit>().getUserById(
      userId: widget.userId,
      myUserId: _myUser.userId,
    );
    _controller = ScrollController();
    _messageController = TextEditingController();

    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state.userEntity == null) {
              return CircularProgressIndicator();
            } else {
              final lastSeen = DateTime.fromMillisecondsSinceEpoch(
                (state.userEntity!.presenceTimestamp * 1000).toInt(),
              );

              final timeAgo = timeAgoText(context, lastSeen);

              Widget? userStatus;

              if (state.userEntity!.presenceStatus == PresenceStatus.active) {
                userStatus = Text(context.t.online, style: theme.textTheme.labelSmall);
              } else {
                userStatus = Text(
                  isJustNow(lastSeen)
                      ? context.t.wasOnlineJustNow
                      : context.t.wasOnline(time: timeAgo),
                  style: theme.textTheme.labelSmall,
                );
              }

              if (state.typingId == state.userEntity!.userId) {
                userStatus = Text(context.t.typing, style: theme.textTheme.labelSmall);
              }
              return Row(
                spacing: 8,
                children: [
                  UserAvatar(avatarUrl: state.userEntity!.avatarUrl),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(state.userEntity!.fullName), userStatus!],
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
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
                padding: EdgeInsetsGeometry.zero,
                child: Column(
                  children: [
                    state.messages.isEmpty && snapshot.connectionState != ConnectionState.waiting
                        ? Expanded(child: Center(child: Text(context.t.noMessagesHereYet)))
                        : Expanded(
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
                              child: snapshot.connectionState == ConnectionState.waiting
                                  ? Skeletonizer(
                                      enabled: true,
                                      child: ListView.separated(
                                        itemCount: 15,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ).copyWith(bottom: 12),
                                        itemBuilder: (context, index) {
                                          return MessageItem(
                                            isMyMessage: index % 2 == 0, // alternate sender
                                            message: MessageEntity.fake(),
                                            isSkeleton: true, // enable skeleton mode
                                            myUserId: _myUser.userId,
                                          );
                                        },
                                      ),
                                    )
                                  : MessagesList(
                                      messages: state.messages,
                                      isLoadingMore: state.isLoadingMore,
                                      controller: _controller,
                                      onRead: (id) {
                                        context.read<ChatCubit>().scheduleMarkAsRead(id);
                                      },
                                      loadMore: context.read<ChatCubit>().loadMoreMessages,
                                      showTopic: true,
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
                                await context.read<ChatCubit>().sendMessage(
                                  chatId: state.userEntity!.userId,
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
