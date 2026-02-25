import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/core/mixins/message/forward_message_mixin.dart';
import 'package:genesis_workspace/core/shortcuts/cancel_select_mode_intent.dart';
import 'package:genesis_workspace/core/shortcuts/unselect_chat_shortcut.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/edit_message_intents.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/mention_navigation_intents.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/utils/web_drop.dart';
import 'package:genesis_workspace/core/widgets/appbar_container.dart';
import 'package:genesis_workspace/core/widgets/channel_app_bar_title.dart';
import 'package:genesis_workspace/core/widgets/input_banner.dart';
import 'package:genesis_workspace/core/widgets/message/chat_text_editing_controller.dart';
import 'package:genesis_workspace/core/widgets/message/mention_suggestions.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/messages_select_app_bar.dart';
import 'package:genesis_workspace/core/widgets/messages_select_footer.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/download_files/view/download_files_button.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ChannelChatView extends StatefulWidget {
  const ChannelChatView({
    super.key,
    required this.chatId,
    required this.channelId,
    this.topicName,
    this.firstMessageId,
    this.focusedMessageId,
    this.leadingOnPressed,
  });

  final int chatId;
  final int channelId;
  final String? topicName;
  final int? firstMessageId;
  final int? focusedMessageId;
  final VoidCallback? leadingOnPressed;

  @override
  State<ChannelChatView> createState() => _ChannelChatViewState();
}

class _ChannelChatViewState extends State<ChannelChatView>
    with ChatWidgetMixin<ChannelChatCubit, ChannelChatView>, WidgetsBindingObserver, ForwardMessageMixin {
  late final Future _future;
  late final UserEntity _myUser;
  late final ScrollController _scrollController;
  final GlobalKey _mentionKey = GlobalKey();
  bool isDraftPasted = false;
  DraftEntity? draftForThisChat;

  Future<void> sendMessage({
    required int streamId,
    String? topicName,
    required List<MessageEntity> selectedMessages,
  }) async {
    final messageContent = messageController.text;
    messageController.clear();
    final forwardMessages = selectedMessages;
    final forwardContent = forwardMessages.map((message) => message.makeForwardedContent()).join('\n');
    final content = '$forwardContent\n$messageContent';
    try {
      await context.read<ChannelChatCubit>().sendMessage(
        streamId: streamId,
        content: content,
        topic: topicName,
      );
      context.read<MessagesSelectCubit>().clearForwardMessages();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      if (platformInfo.isDesktop) {
        messageInputFocusNode.requestFocus();
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _myUser = context.read<ProfileCubit>().state.user!;
    _future = context.read<ChannelChatCubit>().getInitialData(
      streamId: widget.channelId,
      topicName: widget.topicName,
      firstMessageId: widget.focusedMessageId ?? widget.firstMessageId,
      myUserId: _myUser.userId,
    );
    context.read<MessagesSelectCubit>().setSelectMode(false);
    messageController = ChatTextEditingController();
    messageController
      ..addListener(onTextChanged)
      ..addListener(mentionListener);
    focusOnInit();
    draftForThisChat = context.read<DraftsCubit>().getDraftForChat(
      channelId: widget.channelId,
      topicName: widget.topicName,
    );
    if (draftForThisChat != null) {
      messageController.text = draftForThisChat!.content;
      isDraftPasted = true;
    }
    setFocusedMessage(widget.focusedMessageId);
    super.initState();
    if (kIsWeb) {
      removeWebDnD = attachWebDropHandlersForKey(
        targetKey: dropAreaKey,
        onIsOverChange: (over) {
          if (isDropOver != over) {
            setState(() => isDropOver = over);
          }
        },
        onDrop: (dropped) async {
          setState(() => isDropOver = false);
          final nonImageFiles = <PlatformFile>[];
          final imageFiles = <XFile>[];
          for (final item in dropped) {
            final name = item.name;
            final ext = extensionOf(name);
            final bytes = Uint8List.fromList(item.bytes);
            if (isImageExtension(ext)) {
              imageFiles.add(XFile.fromData(bytes, name: name));
            } else {
              nonImageFiles.add(PlatformFile(name: name, size: item.size, bytes: bytes));
            }
          }
          if (nonImageFiles.isNotEmpty) {
            unawaited(
              context.read<ChannelChatCubit>().uploadFilesCommon(droppedFiles: nonImageFiles),
            );
          }
          if (imageFiles.isNotEmpty) {
            unawaited(
              context.read<ChannelChatCubit>().uploadImagesCommon(droppedImages: imageFiles),
            );
          }
        },
      );
      if (events != null) {
        events!.registerPasteEventListener((event) async {
          final reader = await event.getClipboardReader();
          final captured = await pasteCaptureService.captureNow(isWeb: true, webReader: reader);
          handleCaptured(captured);
        });
      }
    }
  }

  @override
  void deactivate() async {
    if (!isDraftPasted && !isEditMode) {
      await saveDraft(
        messageController.text,
        channelId: widget.channelId,
        topicName: widget.topicName,
        type: .stream,
      );
    } else if (!isEditMode) {
      await updateDraft(
        draftForThisChat!.id!,
        messageController.text,
      );
    }

    super.deactivate();
  }

  @override
  void didUpdateWidget(ChannelChatView oldWidget) {
    final oldWidgetInputText = messageController.text;
    if (widget.channelId != oldWidget.channelId) {
      context.read<ChannelChatCubit>().getInitialData(
        streamId: widget.channelId,
        topicName: widget.topicName,
        didUpdateWidget: (oldWidget.topicName != widget.topicName || oldWidget.channelId != widget.channelId),
        firstMessageId: widget.firstMessageId ?? widget.focusedMessageId,
      );
      context.read<MessagesSelectCubit>().setSelectMode(false);
      messageController.clear();
    } else if (widget.topicName != oldWidget.topicName) {
      messageController.clear();
      context.read<MessagesSelectCubit>().setSelectMode(false);
      saveDraft(
        oldWidgetInputText,
        channelId: oldWidget.channelId,
        topicName: oldWidget.topicName,
        type: .stream,
      );
      context.read<ChannelChatCubit>().getChannelTopics(streamId: widget.channelId, topicName: widget.topicName).then((
        _,
      ) {
        context.read<ChannelChatCubit>().getChannelMessages(
          firstMessageId: widget.firstMessageId,
        );
      });
      final draftForThisChat = context.read<DraftsCubit>().getDraftForChat(
        channelId: widget.channelId,
        topicName: widget.topicName,
      );
      if (draftForThisChat != null) {
        messageController.text = draftForThisChat.content;
        isDraftPasted = true;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController
      ..removeListener(onTextChanged)
      ..removeListener(mentionListener);
    messageController.dispose();
    messageInputFocusNode.dispose();
    removeWebDnD?.call();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await context.read<ChannelChatCubit>().getUnreadMessages();
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final iconColors = Theme.of(context).extension<IconColors>()!;
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return BlocConsumer<ChannelChatCubit, ChannelChatState>(
      listenWhen: (prev, current) =>
          prev.uploadFileError != current.uploadFileError || prev.uploadFileErrorName != current.uploadFileErrorName,
      listener: (context, state) {
        if (state.uploadFileError != null && state.uploadFileErrorName != null) {
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(
                SnackBar(
                  content: Column(
                    crossAxisAlignment: .start,
                    spacing: 8,
                    children: [
                      Text(
                        state.uploadFileErrorName!,
                        style: TextStyle(fontWeight: .w600, fontSize: 20),
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
                  context.read<ChannelChatCubit>().clearUploadFileError();
                }
              });
        }
      },
      buildWhen: (prev, current) {
        if (prev.uploadedFiles != current.uploadedFiles) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        return BlocBuilder<MessagesSelectCubit, MessagesSelectState>(
          builder: (context, messagesSelectState) {
            final bool isSelectMode = messagesSelectState.isActive;
            final int selectedCount = messagesSelectState.selectedMessages.length;
            final selectedMessages = messagesSelectState.selectedMessages;
            return Shortcuts(
              shortcuts: {
                SingleActivator(LogicalKeyboardKey.escape, numLock: LockState.ignored): isSelectMode
                    ? CancelSelectModeIntent()
                    : UnselectChatIntent(),
              },
              child: Actions(
                actions: {
                  CancelSelectModeIntent: CancelSelectModeAction(),
                  UnselectChatIntent: UnselectChatAction(),
                },
                child: Focus(
                  autofocus: true,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBarContainer(
                      size: Size.fromHeight(106),
                      appBar: isSelectMode
                          ? MessagesSelectAppBar(selectedCount: selectedCount)
                          : AppBar(
                              toolbarHeight: isTabletOrSmaller ? 76 : null,
                              primary: isTabletOrSmaller,
                              backgroundColor: theme.colorScheme.surface,
                              clipBehavior: .hardEdge,
                              centerTitle: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12).copyWith(
                                  topLeft: isTabletOrSmaller ? .zero : null,
                                  topRight: isTabletOrSmaller ? .zero : null,
                                ),
                              ),
                              actionsPadding: isTabletOrSmaller ? null : .symmetric(horizontal: 20),
                              leading: isTabletOrSmaller
                                  ? IconButton(
                                      onPressed: context.pop,
                                      icon: Assets.icons.arrowLeft.svg(
                                        colorFilter: ColorFilter.mode(
                                          iconColors.base,
                                          .srcIn,
                                        ),
                                      ),
                                    )
                                  : null,
                              // : IconButton(
                              //     onPressed: widget.leadingOnPressed,
                              //     icon: Assets.icons.moreVert.svg(
                              //       colorFilter: ColorFilter.mode(textColors.text30, .srcIn),
                              //     ),
                              //   ),
                              actions: [
                                DownloadFilesButton(),
                                // IconButton(
                                //   onPressed: () {},
                                //   icon: Assets.icons.joinCall.svg(
                                //     width: 28,
                                //     height: 28,
                                //     colorFilter: ColorFilter.mode(AppColors.callGreen, .srcIn),
                                //   ),
                                // ),
                                IconButton(
                                  onPressed: () async {
                                    final meetingLink = await createCall(context, startWithVideoMuted: true);
                                    if (meetingLink.isNotEmpty) {
                                      await context.read<ChannelChatCubit>().sendMessage(
                                        streamId: widget.channelId,
                                        topic: widget.topicName,
                                        content: meetingLink,
                                      );
                                    }
                                  },
                                  icon: Assets.icons.call.svg(
                                    width: 28,
                                    height: 28,
                                    colorFilter: ColorFilter.mode(iconColors.base, BlendMode.srcIn),
                                  ),
                                ),
                                // if (!isTabletOrSmaller)
                                IconButton(
                                  onPressed: () async {
                                    final meetingLink = await createCall(context, startWithVideoMuted: false);
                                    if (meetingLink.isNotEmpty) {
                                      await context.read<ChannelChatCubit>().sendMessage(
                                        streamId: widget.channelId,
                                        topic: widget.topicName,
                                        content: meetingLink,
                                      );
                                    }
                                  },
                                  icon: Assets.icons.videocam.svg(
                                    colorFilter: ColorFilter.mode(iconColors.base, BlendMode.srcIn),
                                  ),
                                ),
                              ],
                              title: Skeletonizer(
                                enabled: state.channel == null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ChannelAppBarTitle(
                                      channelName: state.channel?.name ?? context.t.channel.channelName,
                                      topicName: widget.topicName,
                                      count: state.channel?.subscriberCount ?? 0,
                                      onTap: isTabletOrSmaller
                                          ? () => context.pushNamed(
                                              Routes.channelInfo,
                                              pathParameters: GoRouterState.of(context).pathParameters,
                                            )
                                          : widget.leadingOnPressed,
                                    ),
                                  ],
                                ),
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
                                      (snapshot.connectionState == ConnectionState.waiting || state.isMessagesPending)
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
                                                onTapQuote: (_, {quote}) {},
                                                onTapEditMessage: (_) {},
                                              );
                                            },
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            MessagesList(
                                              messages: state.messages,
                                              controller: _scrollController,
                                              showTopic: state.topic == null,
                                              isLoadingMore: state.isLoadingMore || state.isMessagesPending,
                                              onRead: (id) {
                                                context.read<ChannelChatCubit>().scheduleMarkAsReadCommon(id);
                                              },
                                              loadMorePrev: context.read<ChannelChatCubit>().loadMorePrevMessages,
                                              loadMoreNext: context.read<ChannelChatCubit>().loadMoreNextMessages,
                                              myUserId: _myUser.userId,
                                              onTapQuote: onTapQuote,
                                              onTapEditMessage: onTapEditMessage,
                                              onReadAll: () async {
                                                await context.read<MessengerCubit>().readAllMessages(
                                                  widget.chatId,
                                                  topicName: widget.topicName,
                                                );
                                              },
                                              isSelectMode: messagesSelectState.isActive,
                                              selectedMessages: selectedMessages,
                                              focusedMessageId: focusedMessageId,
                                              foundNewest: state.isFoundNewestMessage,
                                              foundOldest: state.isFoundOldestMessage,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 50,
                                              child: MentionSuggestions(
                                                key: _mentionKey,
                                                mentionFocusNode: mentionFocusNode,
                                                showPopup: state.showMentionPopup,
                                                suggestedMentions: state.suggestedMentions,
                                                isSuggestionsPending: state.isSuggestionsPending,
                                                filteredSuggestedMentions: state.filteredSuggestedMentions,
                                                onSelectMention: onMentionSelected,
                                                inputFocusNode: messageInputFocusNode,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              firstCurve: Curves.easeOut,
                              secondCurve: Curves.easeIn,
                              crossFadeState: isSelectMode ? .showFirst : .showSecond,
                              firstChild: KeyedSubtree(
                                key: const ValueKey<String>('select-footer'),
                                child: MessagesSelectFooter(
                                  count: selectedCount,
                                  onForward: () async {
                                    await onForward(context);
                                  },
                                  onReply: () {
                                    final messagesIds = selectedMessages.map((message) => message.id).toList();
                                    replyMultiMessages(messagesIds);
                                  },
                                ),
                              ),
                              secondChild: DropRegion(
                                formats: Formats.standardFormats,
                                hitTestBehavior: HitTestBehavior.opaque,
                                onDropOver: (DropOverEvent event) async {
                                  if (!isDropOver) {
                                    setState(() {
                                      isDropOver = true;
                                    });
                                  }
                                  return DropOperation.link;
                                },
                                onDropLeave: (_) {
                                  if (isDropOver) {
                                    setState(() {
                                      isDropOver = false;
                                    });
                                  }
                                },
                                onPerformDrop: (PerformDropEvent event) async {
                                  setState(() => isDropOver = false);
                                  final List<PlatformFile> droppedFiles = await toPlatformFiles(event);

                                  final List<PlatformFile> nonImageFiles = <PlatformFile>[];
                                  final List<XFile> imageFiles = <XFile>[];

                                  for (final pf in droppedFiles) {
                                    final ext = extensionOf(pf.name);
                                    if (isImageExtension(ext)) {
                                      if (pf.path != null && pf.path!.isNotEmpty) {
                                        imageFiles.add(XFile(pf.path!, name: pf.name));
                                      } else if (pf.bytes != null) {
                                        imageFiles.add(XFile.fromData(pf.bytes!, name: pf.name));
                                      }
                                    } else {
                                      nonImageFiles.add(pf);
                                    }
                                  }

                                  if (nonImageFiles.isNotEmpty) {
                                    unawaited(
                                      context.read<ChannelChatCubit>().uploadFilesCommon(
                                        droppedFiles: nonImageFiles,
                                      ),
                                    );
                                  }
                                  if (imageFiles.isNotEmpty) {
                                    unawaited(
                                      context.read<ChannelChatCubit>().uploadImagesCommon(
                                        droppedImages: imageFiles,
                                      ),
                                    );
                                  }
                                  if (platformInfo.isDesktop) {
                                    messageInputFocusNode.requestFocus();
                                  }
                                },
                                child: BlocBuilder<ChannelChatCubit, ChannelChatState>(
                                  buildWhen: (prev, current) => prev.uploadedFiles != current.uploadedFiles,
                                  builder: (context, inputState) {
                                    final String _currentText = currentText.trim();
                                    final bool hasText = _currentText.isNotEmpty;

                                    final files = inputState.uploadedFiles;
                                    final bool hasFiles = files.isNotEmpty;
                                    final bool hasUploadingFiles = files.any(
                                      (file) => file is UploadingFileEntity,
                                    );

                                    final bool canSendByTextOnly = hasText && !hasFiles && !hasUploadingFiles;
                                    final bool canSendByFilesOnly = !hasText && hasFiles && !hasUploadingFiles;
                                    final bool canSendByTextAndFiles = hasText && hasFiles && !hasUploadingFiles;
                                    final bool canSendByForwardMessages =
                                        messagesSelectState.selectedMessages.isNotEmpty;

                                    final bool isSendEnabled =
                                        canSendByTextOnly ||
                                        canSendByFilesOnly ||
                                        canSendByTextAndFiles ||
                                        canSendByForwardMessages;

                                    final bool isEditEnabled = isSendEnabled || state.isEdited;

                                    return Actions(
                                      actions: <Type, Action<Intent>>{
                                        PasteTextIntent: ChatPasteAction(
                                          onPaste: () async {
                                            try {
                                              final captured = await pasteCaptureService.captureNow();
                                              handleCaptured(captured);
                                            } catch (e) {
                                              inspect(e);
                                            }
                                          },
                                        ),
                                      },
                                      child: Shortcuts(
                                        shortcuts: state.showMentionPopup
                                            ? {
                                                const SingleActivator(
                                                  LogicalKeyboardKey.arrowDown,
                                                  numLock: LockState.ignored,
                                                ): const MentionNavIntent.down(),
                                                const SingleActivator(
                                                  LogicalKeyboardKey.arrowUp,
                                                  numLock: LockState.ignored,
                                                ): const MentionNavIntent.up(),
                                                const SingleActivator(
                                                  LogicalKeyboardKey.enter,
                                                  numLock: LockState.ignored,
                                                ): const MentionSelectIntent(),
                                                const SingleActivator(
                                                  LogicalKeyboardKey.numpadEnter,
                                                  numLock: LockState.ignored,
                                                ): const MentionSelectIntent(),
                                              }
                                            : {
                                                if (messageController.text.isEmpty)
                                                  const SingleActivator(
                                                    LogicalKeyboardKey.arrowUp,
                                                    numLock: LockState.ignored,
                                                  ): const EditLastMessageIntent(),
                                              },
                                        child: Actions(
                                          actions: {
                                            UnselectChatIntent: UnselectChatAction(),
                                            EditLastMessageIntent: CallbackAction<EditLastMessageIntent>(
                                              onInvoke: (intent) {
                                                final lastMessageIndex = state.messages.lastIndexWhere(
                                                  (message) => message.senderId == state.myUserId,
                                                );
                                                if (lastMessageIndex == -1) return null;

                                                final lastMessage = state.messages[lastMessageIndex];
                                                onTapEditMessage(
                                                  UpdateMessageRequestEntity(
                                                    messageId: lastMessage.id,
                                                    content: lastMessage.content,
                                                  ),
                                                );
                                                return null;
                                              },
                                            ),
                                            MentionNavIntent: CallbackAction<MentionNavIntent>(
                                              onInvoke: (intent) {
                                                if (state.showMentionPopup &&
                                                    state.filteredSuggestedMentions.isNotEmpty) {
                                                  final st = _mentionKey.currentState as dynamic?;
                                                  if (intent.direction == TraversalDirection.down) {
                                                    st?.moveNext();
                                                  } else {
                                                    st?.movePrevious();
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                            MentionSelectIntent: CallbackAction<MentionSelectIntent>(
                                              onInvoke: (intent) {
                                                if (state.showMentionPopup &&
                                                    state.filteredSuggestedMentions.isNotEmpty) {
                                                  final st = _mentionKey.currentState as dynamic?;
                                                  st?.selectFocused();
                                                }
                                                return null;
                                              },
                                            ),
                                          },
                                          child: Container(
                                            key: dropAreaKey,
                                            child: widget.topicName != null
                                                ? MessageInput(
                                                    controller: messageController,
                                                    isMessagePending: state.isMessagePending,
                                                    focusNode: messageInputFocusNode,
                                                    onSubmitIntercept: () {
                                                      if (state.showMentionPopup &&
                                                          state.filteredSuggestedMentions.isNotEmpty) {
                                                        final st = _mentionKey.currentState as dynamic?;
                                                        st?.selectFocused();
                                                        return true;
                                                      }
                                                      return false;
                                                    },
                                                    onSend: isSendEnabled
                                                        ? () {
                                                            unawaited(
                                                              sendMessage(
                                                                streamId: state.channel!.streamId,
                                                                selectedMessages: messagesSelectState.selectedMessages,
                                                                topicName: state.topic?.name,
                                                              ),
                                                            );
                                                          }
                                                        : null,
                                                    onEdit: isEditEnabled
                                                        ? () async {
                                                            try {
                                                              await submitEdit();
                                                            } on DioException catch (e) {
                                                              showErrorSnackBar(context, exception: e);
                                                            } finally {
                                                              if (platformInfo.isDesktop) {
                                                                messageInputFocusNode.requestFocus();
                                                              }
                                                            }
                                                          }
                                                        : null,
                                                    onUploadFile: () async {
                                                      await context.read<ChannelChatCubit>().uploadFilesCommon();
                                                      if (platformInfo.isDesktop) {
                                                        messageInputFocusNode.requestFocus();
                                                      }
                                                    },
                                                    onRemoveFile: context
                                                        .read<ChannelChatCubit>()
                                                        .removeUploadedFileCommon,
                                                    onCancelUpload: context.read<ChannelChatCubit>().cancelUploadCommon,
                                                    files: inputState.uploadedFiles,
                                                    onUploadImage: () async {
                                                      await context.read<ChannelChatCubit>().uploadImagesCommon();
                                                      if (platformInfo.isDesktop) {
                                                        messageInputFocusNode.requestFocus();
                                                      }
                                                    },
                                                    isDropOver: isDropOver,
                                                    onCancelEdit: onCancelEdit,
                                                    isEdit: isEditMode,
                                                    editingMessage: editingMessage,
                                                    editingFiles: state.editingAttachments,
                                                    onRemoveEditingAttachment: (attachment) {
                                                      context.read<ChannelChatCubit>().removeEditingAttachment(
                                                        attachment,
                                                      );
                                                    },
                                                    inputTitle: widget.topicName ?? state.channel?.name,
                                                  )
                                                : InputBanner(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
