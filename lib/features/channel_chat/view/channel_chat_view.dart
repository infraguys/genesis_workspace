import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/utils/web_drop.dart';
import 'package:genesis_workspace/core/widgets/message/mention_suggestions.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class _MentionNavIntent extends Intent {
  const _MentionNavIntent._(this.direction);
  const _MentionNavIntent.down() : this._(TraversalDirection.down);
  const _MentionNavIntent.up() : this._(TraversalDirection.up);
  final TraversalDirection direction;
}

class _MentionSelectIntent extends Intent {
  const _MentionSelectIntent();
}

class ChannelChatView extends StatefulWidget {
  final int channelId;
  final String? topicName;
  final int? unreadMessagesCount;

  const ChannelChatView({
    super.key,
    required this.channelId,
    this.topicName,
    this.unreadMessagesCount = 0,
  });

  @override
  State<ChannelChatView> createState() => _ChannelChatViewState();
}

class _ChannelChatViewState extends State<ChannelChatView>
    with ChatWidgetMixin<ChannelChatCubit, ChannelChatView>, WidgetsBindingObserver {
  late final Future _future;
  late final UserEntity _myUser;
  late final ScrollController _scrollController;
  final GlobalKey _mentionKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _myUser = context.read<ProfileCubit>().state.user!;
    _future = context.read<ChannelChatCubit>().getInitialData(
      streamId: widget.channelId,
      topicName: widget.topicName,
      unreadMessagesCount: widget.unreadMessagesCount,
    );
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
  void didUpdateWidget(ChannelChatView oldWidget) {
    if (widget.channelId != oldWidget.channelId) {
      context.read<ChannelChatCubit>().getInitialData(
        streamId: widget.channelId,
        topicName: widget.topicName,
        didUpdateWidget:
            (oldWidget.topicName != widget.topicName || oldWidget.channelId != widget.channelId),
      );
    } else if (widget.topicName != oldWidget.topicName) {
      context
          .read<ChannelChatCubit>()
          .getChannelTopics(streamId: widget.channelId, topicName: widget.topicName)
          .then((_) {
            context.read<ChannelChatCubit>().getChannelMessages(
              unreadMessagesCount: widget.unreadMessagesCount,
            );
          });
    }

    messageController.clear();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
    return BlocConsumer<ChannelChatCubit, ChannelChatState>(
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
                  context.read<ChannelChatCubit>().clearUploadFileErrorCommon();
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
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: false,
            title: Skeletonizer(
              enabled: state.channel == null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.channel?.name ?? 'Channel Name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.topicName != null)
                    Text(
                      widget.topicName!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                ],
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
                                    controller: _scrollController,
                                    showTopic: state.topic == null,
                                    isLoadingMore: state.isLoadingMore || state.isMessagesPending,
                                    onRead: (id) {
                                      context.read<ChannelChatCubit>().scheduleMarkAsReadCommon(id);
                                    },
                                    loadMore: context.read<ChannelChatCubit>().loadMoreMessages,
                                    myUserId: _myUser.userId,
                                    onTapQuote: onTapQuote,
                                    onTapEditMessage: onTapEditMessage,
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
                          child: Shortcuts(
                            shortcuts: state.showMentionPopup
                                ? <ShortcutActivator, Intent>{
                                    LogicalKeySet(LogicalKeyboardKey.arrowDown): const _MentionNavIntent.down(),
                                    LogicalKeySet(LogicalKeyboardKey.arrowUp): const _MentionNavIntent.up(),
                                    LogicalKeySet(LogicalKeyboardKey.enter): const _MentionSelectIntent(),
                                    LogicalKeySet(LogicalKeyboardKey.numpadEnter): const _MentionSelectIntent(),
                                  }
                                : const <ShortcutActivator, Intent>{},
                            child: Actions(
                              actions: <Type, Action<Intent>>{
                                _MentionNavIntent: CallbackAction<_MentionNavIntent>(
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
                                _MentionSelectIntent: CallbackAction<_MentionSelectIntent>(
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
                                            await context.read<ChannelChatCubit>().sendMessage(
                                              streamId: state.channel!.streamId,
                                              content: content,
                                              topic: state.topic?.name,
                                            );
                                          } catch (e) {
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
        );
      },
    );
  }
}
