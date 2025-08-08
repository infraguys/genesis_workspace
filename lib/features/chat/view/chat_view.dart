import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/widgets/message_input.dart';
import 'package:genesis_workspace/core/widgets/message_item.dart';
import 'package:genesis_workspace/core/widgets/messages_list.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatView extends StatefulWidget {
  final DmUserEntity userEntity;

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
        title: Row(
          spacing: 8,
          children: [
            UserAvatar(avatarUrl: widget.userEntity.avatarUrl),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final lastSeen = DateTime.fromMillisecondsSinceEpoch(
                  (widget.userEntity.presenceTimestamp * 1000).toInt(),
                );

                final timeAgo = timeAgoText(context, lastSeen);

                Widget? userStatus;

                if (widget.userEntity.presenceStatus == PresenceStatus.active) {
                  userStatus = Text(context.t.online, style: theme.textTheme.labelSmall);
                } else {
                  userStatus = Text(
                    isJustNow(lastSeen)
                        ? context.t.wasOnlineJustNow
                        : context.t.wasOnline(time: timeAgo),
                    style: theme.textTheme.labelSmall,
                  );
                }

                if (state.typingId == widget.userEntity.userId) {
                  userStatus = Text(context.t.typing, style: theme.textTheme.labelSmall);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(widget.userEntity.fullName), userStatus],
                );
              },
            ),
          ],
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
                // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                              // : Column(
                              //     children: [
                              //       if (state.isLoadingMore) const LinearProgressIndicator(),
                              //       Expanded(
                              //         child: ListView.separated(
                              //           controller: _controller,
                              //           reverse: true,
                              //           itemCount: state.messages.length,
                              //           padding: EdgeInsets.symmetric(
                              //             horizontal: 12,
                              //           ).copyWith(bottom: 12),
                              //           separatorBuilder: (BuildContext context, int index) {
                              //             return SizedBox(height: 12);
                              //           },
                              //           itemBuilder: (BuildContext context, int index) {
                              //             final message = state.messages.reversed
                              //                 .toList()[index];
                              //             final isMyMessage =
                              //                 message.senderId == _myUser.userId;
                              //
                              //             return VisibilityDetector(
                              //               key: Key('message-${message.id}'),
                              //               onVisibilityChanged: (info) {
                              //                 final visiblePercentage =
                              //                     info.visibleFraction * 100;
                              //
                              //                 if (visiblePercentage > 50 &&
                              //                     (message.flags == null ||
                              //                         message.flags!.isEmpty)) {
                              //                   context.read<ChatCubit>().scheduleMarkAsRead(
                              //                     message.id,
                              //                   );
                              //                 }
                              //               },
                              //               child: MessageItem(
                              //                 isMyMessage: isMyMessage,
                              //                 message: message,
                              //               ),
                              //             );
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
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
