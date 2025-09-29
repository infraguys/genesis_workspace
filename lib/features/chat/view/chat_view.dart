import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/utils/web_drop.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ChatView extends StatefulWidget {
  final int userId;
  final int? unreadMessagesCount;

  const ChatView({super.key, required this.userId, this.unreadMessagesCount = 0});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with ChatWidgetMixin<ChatCubit, ChatView>, WidgetsBindingObserver {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;

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
    messageController = TextEditingController();

    messageController
      ..addListener(onTextChanged)
      ..addListener(mentionListener);
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
              return Column(
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
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 50,
                                        child: AnimatedOpacity(
                                          opacity: state.showMentionPopup ? 1 : 0,
                                          duration: const Duration(milliseconds: 100),
                                          curve: Curves.easeInOut,
                                          child: Material(
                                            elevation: 8,
                                            borderRadius: BorderRadius.circular(12),
                                            color: theme.colorScheme.surface,
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            child: Container(
                                              width: 300,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Builder(
                                                builder: (context) {
                                                  if (state.suggestedMentions.isEmpty &&
                                                      state.isSuggestionsPending) {
                                                    return Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  }
                                                  if (state.filteredSuggestedMentions.isEmpty) {
                                                    return Center(
                                                      child: Text(
                                                        context.t.nothingFound,
                                                        style: theme.textTheme.bodyMedium!.copyWith(
                                                          color: theme.colorScheme.onSurface
                                                              .withValues(alpha: 0.4),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return Column(
                                                    children: [
                                                      if (state.isSuggestionsPending)
                                                        LinearProgressIndicator(),
                                                      Expanded(
                                                        child: ListView.separated(
                                                          padding: const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                          itemCount: state
                                                              .filteredSuggestedMentions
                                                              .length,
                                                          separatorBuilder: (_, _) =>
                                                              const SizedBox(height: 4),
                                                          itemBuilder: (context, index) {
                                                            final UserEntity user = state
                                                                .filteredSuggestedMentions[index];
                                                            return InkWell(
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 12,
                                                                  vertical: 10,
                                                                ),
                                                                child: Text(
                                                                  user.fullName,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: Theme.of(
                                                                    context,
                                                                  ).textTheme.bodyMedium,
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
                        final bool canSendByTextAndFiles =
                            hasText && hasFiles && !hasUploadingFiles;

                        final bool isSendEnabled =
                            canSendByTextOnly || canSendByFilesOnly || canSendByTextAndFiles;
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
                          child: Container(
                            key: dropAreaKey,
                            child: MessageInput(
                              controller: messageController,
                              isMessagePending: state.isMessagePending,
                              focusNode: messageInputFocusNode,
                              onSend: isSendEnabled
                                  ? () async {
                                      final content = messageController.text;
                                      messageController.clear();
                                      try {
                                        await context.read<ChatCubit>().sendMessage(
                                          chatId: state.userEntity!.userId,
                                          content: content,
                                        );
                                      } catch (e) {
                                        inspect(e);
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
        );
      },
    );
  }
}
