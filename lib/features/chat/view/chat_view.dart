import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatView extends StatefulWidget {
  final int userId;
  final int? unreadMessagesCount;

  const ChatView({super.key, required this.userId, this.unreadMessagesCount = 0});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;
  late final TextEditingController _messageController;

  final FocusNode _messageInputFocusNode = FocusNode();

  String _currentText = '';

  Future<void> _onTextChanged() async {
    setState(() {
      _currentText = _messageController.text;
    });
    await context.read<ChatCubit>().changeTyping(
      op: _currentText.isEmpty ? TypingEventOp.stop : TypingEventOp.start,
    );
  }

  void insertQuoteAndFocus({required String textToInsert, bool append = false}) {
    final String current = _messageController.text;
    final String nextText = append && current.isNotEmpty ? '$current\n$textToInsert' : textToInsert;

    _messageController.text = nextText;
    _messageController.selection = TextSelection.collapsed(offset: nextText.length);
    _messageInputFocusNode.requestFocus();
  }

  Future<void> onTapQuote(int messageId) async {
    try {
      context.read<ChatCubit>().setIsMessagePending(true);

      final singleMessage = await context.read<MessagesCubit>().getMessageById(
        messageId: messageId,
        applyMarkdown: false,
      );

      final String quote = generateMessageQuote(singleMessage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        insertQuoteAndFocus(textToInsert: quote);
      });
    } catch (e) {
    } finally {
      context.read<ChatCubit>().setIsMessagePending(false);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _myUser = context.read<ProfileCubit>().state.user!;

    _future = context.read<ChatCubit>().getInitialData(
      userId: widget.userId,
      myUserId: _myUser.userId,
      unreadMessagesCount: widget.unreadMessagesCount,
    );
    _controller = ScrollController();
    _messageController = TextEditingController();

    _messageController.addListener(_onTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _messageInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (prev, current) =>
          prev.uploadFileError != current.uploadFileError ||
          prev.uploadFileErrorName != current.uploadFileErrorName,
      listener: (context, state) {
        if (state.uploadFileError != null && state.uploadFileErrorName != null) {
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(
                SnackBar(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        state.uploadFileErrorName!,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      Text(state.uploadFileError!),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              )
              .closed
              .then((_) {
                if (context.mounted) {
                  context.read<ChatCubit>().clearUploadFileErrorCommon();
                }
              });
        }
      },
      buildWhen: (prev, current) {
        if (prev.uploadedFiles != current.uploadedFiles) {
          return false;
        } else {
          return true;
        }
      },
      builder: (context, state) {
        final isLoading = state.userEntity == null;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Builder(
              builder: (context) {
                if (isLoading) {
                  return Skeletonizer(
                    child: Row(
                      spacing: 8,
                      children: [
                        UserAvatar(),
                        BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text("User Userov"), Text(context.t.online)],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                final lastSeen = DateTime.fromMillisecondsSinceEpoch(
                  (state.userEntity!.presenceTimestamp * 1000).toInt(),
                );
                final timeAgo = timeAgoText(context, lastSeen);

                Widget userStatus;
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
                          children: [Text(state.userEntity!.fullName), userStatus],
                        );
                      },
                    ),
                  ],
                );
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
                                        itemCount: 20,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ).copyWith(bottom: 12),
                                        itemBuilder: (context, index) {
                                          return MessageItem(
                                            isMyMessage: index % 2 == 0,
                                            message: MessageEntity.fake(),
                                            isSkeleton: true,
                                            myUserId: _myUser.userId,
                                            onTapQuote: (_) {},
                                          );
                                        },
                                      ),
                                    )
                                  : MessagesList(
                                      messages: state.messages,
                                      isLoadingMore: state.isLoadingMore,
                                      controller: _controller,
                                      onRead: (id) {
                                        context.read<ChatCubit>().scheduleMarkAsReadCommon(id);
                                      },
                                      loadMore: context.read<ChatCubit>().loadMoreMessages,
                                      showTopic: true,
                                      myUserId: _myUser.userId,
                                      onTapQuote: onTapQuote,
                                    ),
                            ),
                          ),
                    BlocBuilder<ChatCubit, ChatState>(
                      buildWhen: (prev, current) => (prev.uploadedFiles != current.uploadedFiles),
                      builder: (context, inputState) {
                        final bool hasText = _currentText.trim().isNotEmpty;
                        final bool hasUploadingFiles = inputState.uploadedFiles.any(
                          (file) => file is UploadingFileEntity,
                        );
                        final bool allFilesReady =
                            inputState.uploadedFiles.every((file) => file is UploadedFileEntity) &&
                            inputState.uploadedFiles.isNotEmpty;

                        final bool isSendEnabled = hasText || (!hasUploadingFiles && allFilesReady);
                        final bool isSendDisabled = !isSendEnabled;
                        return MessageInput(
                          controller: _messageController,
                          isMessagePending: state.isMessagePending,
                          focusNode: _messageInputFocusNode,
                          onSend: isSendDisabled
                              ? null
                              : () async {
                                  final content = _messageController.text;
                                  _messageController.clear();
                                  try {
                                    await context.read<ChatCubit>().sendMessage(
                                      chatId: inputState.userEntity!.userId,
                                      content: content,
                                    );
                                  } catch (e) {}
                                },
                          onUploadFile: () async {
                            await context.read<ChatCubit>().uploadFilesCommon();
                          },
                          onRemoveFile: context.read<ChatCubit>().removeUploadedFileCommon,
                          onCancelUpload: context.read<ChatCubit>().cancelUploadCommon,
                          files: inputState.uploadedFiles,
                          onUploadImage: () async {
                            await context.read<ChatCubit>().uploadImagesCommon();
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
