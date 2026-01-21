import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/core/shortcuts/unselect_chat_shortcut.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/edit_message_intents.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/mention_navigation_intents.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/utils/web_drop.dart';
import 'package:genesis_workspace/core/widgets/appbar_container.dart';
import 'package:genesis_workspace/core/widgets/message/chat_text_editing_controller.dart';
import 'package:genesis_workspace/core/widgets/message/mention_suggestions.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/download_files/view/download_files_button.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    this.chatId = -1,
    required this.userIds,
    this.unreadMessagesCount = 0,
    this.leadingOnPressed,
  });

  final int? chatId;
  final List<int> userIds;
  final int? unreadMessagesCount;
  final VoidCallback? leadingOnPressed;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with ChatWidgetMixin<ChatCubit, ChatView>, WidgetsBindingObserver {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;
  final GlobalKey _mentionKey = GlobalKey();
  bool isDraftPasted = false;
  DraftEntity? draftForThisChat;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _myUser = context.read<ProfileCubit>().state.user!;
    _future = context.read<ChatCubit>().getInitialData(
      userIds: widget.userIds,
      myUserId: _myUser.userId,
      unreadMessagesCount: widget.unreadMessagesCount,
    );
    _controller = ScrollController();
    messageController = ChatTextEditingController();
    messageController
      ..addListener(onTextChanged)
      ..addListener(mentionListener);
    focusOnInit();
    final otherUserIds = widget.userIds.length == 1
        ? widget.userIds
        : widget.userIds.where((id) => id != _myUser.userId).toList(growable: false);
    draftForThisChat = context.read<DraftsCubit>().getDraftForChat(userIds: otherUserIds);
    if (draftForThisChat != null) {
      messageController.text = draftForThisChat!.content;
      isDraftPasted = true;
    }
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
            unawaited(context.read<ChatCubit>().uploadFilesCommon(droppedFiles: nonImageFiles));
          }
          if (imageFiles.isNotEmpty) {
            unawaited(context.read<ChatCubit>().uploadImagesCommon(droppedImages: imageFiles));
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await context.read<ChatCubit>().getUnreadMessages();
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void deactivate() async {
    if (!isDraftPasted && !isEditMode) {
      await saveDraft(
        messageController.text,
        chatId: widget.chatId!,
        userIds: widget.userIds,
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    messageController
      ..removeListener(onTextChanged)
      ..removeListener(mentionListener);
    messageController.dispose();
    messageInputFocusNode.dispose();
    removeWebDnD?.call();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return BlocConsumer<ChatCubit, ChatState>(
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
                  context.read<ChatCubit>().clearUploadFileError();
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
        final isLoading = state.userEntity == null && state.groupUsers == null;

        return Shortcuts(
          shortcuts: {
            SingleActivator(LogicalKeyboardKey.escape, numLock: LockState.ignored): UnselectChatIntent(),
          },
          child: Actions(
            actions: {
              UnselectChatIntent: UnselectChatAction(),
            },
            child: Focus(
              autofocus: true,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBarContainer(
                  appBar: AppBar(
                    primary: isTabletOrSmaller,
                    backgroundColor: theme.colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12).copyWith(
                        topLeft: isTabletOrSmaller ? .zero : null,
                        topRight: isTabletOrSmaller ? .zero : null,
                      ),
                    ),
                    clipBehavior: .hardEdge,
                    centerTitle: false,
                    actionsPadding: isTabletOrSmaller
                        ? null
                        : EdgeInsetsGeometry.symmetric(
                            horizontal: 20,
                          ),
                    leading: isTabletOrSmaller
                        ? IconButton(
                            onPressed: () {
                              context.pop();
                            },
                            icon: Icon(
                              CupertinoIcons.back,
                              color: textColors.text30,
                            ),
                          )
                        : IconButton(
                            onPressed: widget.leadingOnPressed,
                            icon: Assets.icons.moreVert.svg(
                              colorFilter: ColorFilter.mode(textColors.text30, BlendMode.srcIn),
                            ),
                          ),
                    actions: [
                      DownloadFilesButton(),
                      IconButton(
                        onPressed: () async {
                          final meetingLink = await createCall(context, startWithVideoMuted: true);
                          if (meetingLink.isNotEmpty) {
                            await context.read<ChatCubit>().sendMessage(content: meetingLink);
                          }
                        },
                        icon: Assets.icons.call.svg(
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(textColors.text50, BlendMode.srcIn),
                        ),
                      ),
                      // if (!isTabletOrSmaller)
                      IconButton(
                        onPressed: () async {
                          final meetingLink = await createCall(context, startWithVideoMuted: false);
                          if (meetingLink.isNotEmpty) {
                            await context.read<ChatCubit>().sendMessage(content: meetingLink);
                          }
                        },
                        icon: Assets.icons.videocam.svg(
                          colorFilter: ColorFilter.mode(textColors.text50, BlendMode.srcIn),
                        ),
                      ),
                    ],
                    title: Builder(
                      builder: (context) {
                        final titleTextStyle = theme.textTheme.labelLarge?.copyWith(
                          fontSize: isTabletOrSmaller ? 14 : 16,
                        );
                        final subtitleTextStyle = theme.textTheme.bodySmall?.copyWith(
                          color: textColors.text30,
                        );
                        if (isLoading) {
                          return Skeletonizer(
                            child: Row(
                              spacing: 8,
                              children: [
                                if (currentSize(context) > ScreenSize.tablet) UserAvatar(),
                                BlocBuilder<ChatCubit, ChatState>(
                                  builder: (context, state) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "User Userov",
                                          style: titleTextStyle,
                                        ),
                                        Text(
                                          context.t.online,
                                          style: subtitleTextStyle,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }

                        if (state.userEntity != null) {
                          final userEntity = state.userEntity ?? UserEntity.fake().toDmUser();

                          final lastSeen = DateTime.fromMillisecondsSinceEpoch(
                            (userEntity.presenceTimestamp * 1000).toInt(),
                          );
                          final timeAgo = timeAgoText(context, lastSeen);

                          Widget userStatus;
                          if (userEntity.presenceStatus == PresenceStatus.active) {
                            userStatus = Text(
                              context.t.online,
                              style: subtitleTextStyle,
                            );
                          } else {
                            userStatus = Text(
                              isJustNow(lastSeen) ? context.t.wasOnlineJustNow : context.t.wasOnline(time: timeAgo),
                              style: subtitleTextStyle,
                            );
                          }
                          if (userEntity.userId == _myUser.userId) {
                            userStatus = SizedBox.shrink();
                          }
                          if (userEntity.isBot) {
                            userStatus = Text(
                              context.t.bot,
                              style: subtitleTextStyle,
                            );
                          }
                          if (state.typingId == userEntity.userId) {
                            userStatus = Text(context.t.typing, style: subtitleTextStyle);
                          }

                          return Row(
                            spacing: 8,
                            children: [
                              if (!isTabletOrSmaller) UserAvatar(avatarUrl: userEntity.avatarUrl),
                              BlocBuilder<ChatCubit, ChatState>(
                                builder: (context, state) {
                                  return GestureDetector(
                                    onTap: () {
                                      context.pushNamed(
                                        Routes.chatInfo,
                                        pathParameters: GoRouterState.of(context).pathParameters,
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          userEntity.fullName,
                                          style: titleTextStyle,
                                        ),
                                        userStatus,
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        } else if (state.groupUsers != null) {
                          final users = state.groupUsers!;
                          final names = users.map((u) => u.fullName).join(', ');

                          return Row(
                            spacing: 8,
                            children: [
                              const CircleAvatar(child: Icon(Icons.groups)),
                              Column(
                                crossAxisAlignment: .start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.55,
                                    ),
                                    child: Text(
                                      names,
                                      style: titleTextStyle,
                                      overflow: .ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text(
                                    context.t.group.membersCount(count: users.length),
                                    style: subtitleTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                body: FutureBuilder(
                  future: _future,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == .done) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error"));
                      }
                    }
                    return Column(
                      children: [
                        state.messages.isEmpty && snapshot.connectionState != .waiting
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
                                  child: snapshot.connectionState == .waiting
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
                                                onTapEditMessage: (_) {},
                                              );
                                            },
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            MessagesList(
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
                                              onTapEditMessage: onTapEditMessage,
                                              onReadAll: () async {
                                                if (widget.chatId != null) {
                                                  await context.read<MessengerCubit>().readAllMessages(
                                                    widget.chatId!,
                                                  );
                                                }
                                              },
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
                        DropRegion(
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

                            // Split into image files and other files
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
                            try {
                              if (nonImageFiles.isNotEmpty) {
                                unawaited(
                                  context.read<ChatCubit>().uploadFilesCommon(droppedFiles: nonImageFiles),
                                );
                              }
                              if (imageFiles.isNotEmpty) {
                                unawaited(
                                  context.read<ChatCubit>().uploadImagesCommon(droppedImages: imageFiles),
                                );
                              }
                              if (platformInfo.isDesktop) {
                                messageInputFocusNode.requestFocus();
                              }
                            } catch (e) {
                              inspect(e);
                            }
                          },
                          child: BlocBuilder<ChatCubit, ChatState>(
                            buildWhen: (prev, current) => (prev.uploadedFiles != current.uploadedFiles),
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

                              final bool isSendEnabled =
                                  canSendByTextOnly || canSendByFilesOnly || canSendByTextAndFiles;
                              final bool isEditEnabled = isSendEnabled || state.isEdited;

                              return Actions(
                                actions: {
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
                                          const SingleActivator(.arrowDown, numLock: .ignored):
                                              const MentionNavIntent.down(),
                                          const SingleActivator(.arrowUp, numLock: .ignored):
                                              const MentionNavIntent.up(),
                                          const SingleActivator(.enter, numLock: .ignored): const MentionSelectIntent(),
                                          const SingleActivator(.numpadEnter, numLock: .ignored):
                                              const MentionSelectIntent(),
                                        }
                                      : {
                                          if (messageController.text.isEmpty)
                                            const SingleActivator(.arrowUp, numLock: .ignored):
                                                const EditLastMessageIntent(),
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
                                          if (state.showMentionPopup && state.filteredSuggestedMentions.isNotEmpty) {
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
                                          if (state.showMentionPopup && state.filteredSuggestedMentions.isNotEmpty) {
                                            final st = _mentionKey.currentState as dynamic?;
                                            st?.selectFocused();
                                          }
                                          return null;
                                        },
                                      ),
                                    },
                                    child: Container(
                                      key: dropAreaKey,
                                      child: MessageInput(
                                        controller: messageController,
                                        isMessagePending: state.isMessagePending,
                                        focusNode: messageInputFocusNode,
                                        onSubmitIntercept: () {
                                          if (state.showMentionPopup && state.filteredSuggestedMentions.isNotEmpty) {
                                            final st = _mentionKey.currentState as dynamic?;
                                            st?.selectFocused();
                                            return true;
                                          }
                                          return false;
                                        },
                                        onSend: isSendEnabled
                                            ? () async {
                                                final content = messageController.text;
                                                messageController.clear();
                                                try {
                                                  await context.read<ChatCubit>().sendMessage(content: content);
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
                                          await context.read<ChatCubit>().uploadFilesCommon();
                                          if (platformInfo.isDesktop) {
                                            messageInputFocusNode.requestFocus();
                                          }
                                        },
                                        onRemoveFile: context.read<ChatCubit>().removeUploadedFileCommon,
                                        onCancelUpload: context.read<ChatCubit>().cancelUploadCommon,
                                        files: inputState.uploadedFiles,
                                        onUploadImage: () async {
                                          await context.read<ChatCubit>().uploadImagesCommon();
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
                                          context.read<ChatCubit>().removeEditingAttachment(attachment);
                                        },
                                        inputTitle: state.userEntity?.fullName,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
  }
}
