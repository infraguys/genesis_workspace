import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/edit_message_intents.dart';
import 'package:genesis_workspace/core/utils/message_input_intents/mention_navigation_intents.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/utils/web_drop.dart';
import 'package:genesis_workspace/core/widgets/message/chat_text_editing_controller.dart';
import 'package:genesis_workspace/core/widgets/message/mention_suggestions.dart';
import 'package:genesis_workspace/core/widgets/message/message_input.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/download_files/entities/download_file_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ChatView extends StatefulWidget {
  final List<int> userIds;
  final int? unreadMessagesCount;

  const ChatView({super.key, required this.userIds, this.unreadMessagesCount = 0});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with ChatWidgetMixin<ChatCubit, ChatView>, WidgetsBindingObserver {
  late final Future _future;
  late final ScrollController _controller;
  late final UserEntity _myUser;
  final GlobalKey _mentionKey = GlobalKey();
  final GlobalKey<CustomPopupState> _downloadFilesKey = GlobalKey();
  bool _showDownloadFinishedIcon = false;
  Timer? _downloadFinishedTimer;

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
    _downloadFinishedTimer?.cancel();

    super.dispose();
  }

  Widget? _buildDownloadSubtitle(DownloadFileEntity file, ThemeData theme) {
    if (file is! DownloadingFileEntity) return Text('Готово', style: theme.textTheme.bodySmall);

    final int progress = file.progress;
    final int total = file.total;
    if (total <= 0) {
      return Text(
        '${_formatBytes(progress)}',
        style: theme.textTheme.bodySmall,
      );
    }
    final double percent = (progress / total * 100).clamp(0, 100);
    return Text(
      '${percent.toStringAsFixed(0)}% • ${_formatBytes(progress)} / ${_formatBytes(total)}',
      style: theme.textTheme.bodySmall,
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int i = 0;
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    final String formatted = size >= 10 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
    return '$formatted ${suffixes[i]}';
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

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            primary: isTabletOrSmaller,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12).copyWith(
                topLeft: isTabletOrSmaller ? Radius.zero : null,
                topRight: isTabletOrSmaller ? Radius.zero : null,
              ),
            ),
            clipBehavior: Clip.hardEdge,
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
                    onPressed: () {},
                    icon: Assets.icons.moreVert.svg(
                      colorFilter: ColorFilter.mode(textColors.text30, BlendMode.srcIn),
                    ),
                  ),
            actions: [
              // IconButton(
              //   onPressed: () {},
              //   icon: Assets.icons.joinCall.svg(
              //     width: 28,
              //     height: 28,
              //     colorFilter: ColorFilter.mode(AppColors.callGreen, BlendMode.srcIn),
              //   ),
              // ),
              BlocConsumer<DownloadFilesCubit, DownloadFilesState>(
                listenWhen: (prev, current) => prev.isFinished != current.isFinished,
                listener: (context, state) {
                  if (!mounted) return;
                  if (!state.isFinished) {
                    _downloadFinishedTimer?.cancel();
                    if (_showDownloadFinishedIcon) {
                      setState(() => _showDownloadFinishedIcon = false);
                    }
                    return;
                  }
                  if (state.files.isEmpty) return;
                  _downloadFinishedTimer?.cancel();
                  setState(() => _showDownloadFinishedIcon = true);
                  _downloadFinishedTimer = Timer(const Duration(seconds: 1), () {
                    if (!mounted) return;
                    setState(() => _showDownloadFinishedIcon = false);
                  });
                },
                builder: (context, state) {
                  final lastDownloadingFile = state.files.lastWhere(
                    (file) => file is DownloadingFileEntity,
                    orElse: () => DownloadedFileEntity(pathToFile: "-1", fileName: '', bytes: Uint8List(0)),
                  );
                  if (state.files.isNotEmpty) {
                    final bool showSuccessIcon = state.isFinished && _showDownloadFinishedIcon;
                    return CustomPopup(
                      key: _downloadFilesKey,
                      rootNavigator: true,
                      position: PopupPosition.bottom,
                      backgroundColor: theme.colorScheme.surface,
                      content: Container(
                        width: 240,
                        constraints: const BoxConstraints(maxHeight: 260),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: state.files.isEmpty
                            ? Center(
                                child: Text(
                                  'Нет загрузок',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: textColors.text30),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                itemCount: state.files.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (BuildContext context, int index) {
                                  final file = state.files[index];
                                  return ListTile(
                                    dense: false,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    leading: Builder(
                                      builder: (BuildContext context) {
                                        if (file is DownloadingFileEntity) {
                                          final double? value = file.total > 0 ? file.progress / file.total : null;
                                          return SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              value: value != null ? value.clamp(0, 1) : null,
                                            ),
                                          );
                                        }
                                        return CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.callGreen.withValues(alpha: 0.15),
                                          child: Icon(Icons.check, size: 18, color: AppColors.callGreen),
                                        );
                                      },
                                    ),
                                    title: Text(
                                      file.fileName,
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: _buildDownloadSubtitle(file, theme),
                                  );
                                },
                              ),
                      ),
                      child: Stack(
                        alignment: AlignmentGeometry.center,
                        children: [
                          if (!state.isFinished && !showSuccessIcon && lastDownloadingFile is DownloadingFileEntity)
                            CircularProgressIndicator(
                              value: lastDownloadingFile.progress / lastDownloadingFile.total,
                            ),
                          IconButton(
                            onPressed: () {
                              _downloadFilesKey.currentState?.show();
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                final bool isCheck = child.key == const ValueKey('downloadFinished');
                                if (isCheck) {
                                  final slideAnimation = Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.bounceInOut)).animate(animation);
                                  final bounceScale = CurvedAnimation(parent: animation, curve: Curves.elasticOut);

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: slideAnimation,
                                      child: ScaleTransition(scale: bounceScale, child: child),
                                    ),
                                  );
                                }

                                final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(scale: curved, child: child),
                                );
                              },
                              child: showSuccessIcon
                                  ? Icon(
                                      Icons.check,
                                      key: const ValueKey('downloadFinished'),
                                      color: AppColors.callGreen,
                                    )
                                  : Icon(
                                      Icons.file_download_outlined,
                                      key: const ValueKey('downloadInProgress'),
                                      color: state.isFinished ? AppColors.callGreen : textColors.text30,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              IconButton(
                onPressed: () {},
                icon: Assets.icons.call.svg(
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(textColors.text50, BlendMode.srcIn),
                ),
              ),
              if (!isTabletOrSmaller)
                IconButton(
                  onPressed: () {},
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
                  if (state.typingId == userEntity.userId) {
                    userStatus = Text(context.t.typing, style: subtitleTextStyle);
                  }

                  return Row(
                    spacing: 8,
                    children: [
                      if (!isTabletOrSmaller) UserAvatar(avatarUrl: userEntity.avatarUrl),
                      BlocBuilder<ChatCubit, ChatState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userEntity.fullName,
                                style: titleTextStyle,
                              ),
                              userStatus,
                            ],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.55,
                            ),
                            child: Text(
                              names,
                              style: titleTextStyle,
                              overflow: TextOverflow.ellipsis,
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

                        final bool isSendEnabled = canSendByTextOnly || canSendByFilesOnly || canSendByTextAndFiles;
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
                                    LogicalKeySet(LogicalKeyboardKey.arrowDown): const MentionNavIntent.down(),
                                    LogicalKeySet(LogicalKeyboardKey.arrowUp): const MentionNavIntent.up(),
                                    LogicalKeySet(LogicalKeyboardKey.enter): const MentionSelectIntent(),
                                    LogicalKeySet(LogicalKeyboardKey.numpadEnter): const MentionSelectIntent(),
                                  }
                                : <ShortcutActivator, Intent>{
                                    LogicalKeySet(LogicalKeyboardKey.arrowUp): const EditLastMessageIntent(),
                                    LogicalKeySet(LogicalKeyboardKey.escape): const CancelEditMessageIntent(),
                                  },
                            child: Actions(
                              actions: <Type, Action<Intent>>{
                                CancelEditMessageIntent: CallbackAction<CancelEditMessageIntent>(
                                  onInvoke: (_) {
                                    if (isEditMode) {
                                      onCancelEdit();
                                    }
                                    return null;
                                  },
                                ),
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
                                            await context.read<ChatCubit>().sendMessage(
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
        );
      },
    );
  }
}
