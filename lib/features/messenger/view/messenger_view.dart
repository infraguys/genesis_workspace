import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/mixins/chat/open_dm_chat_mixin.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_topics_list.dart';
import 'package:genesis_workspace/features/messenger/view/create_folder_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/info_panel.dart';
import 'package:genesis_workspace/features/messenger/view/messenger_app_bar.dart';
import 'package:genesis_workspace/features/messenger/view/update_folder_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/active_call_panel.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/messenger_folder_rail.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/pinned_chats_section.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class MessengerView extends StatefulWidget {
  const MessengerView({super.key});

  @override
  State<MessengerView> createState() => _MessengerViewState();
}

class _MessengerViewState extends State<MessengerView>
    with SingleTickerProviderStateMixin, OpenDmChatMixin, WidgetsBindingObserver {
  static const Duration _searchAnimationDuration = Duration(milliseconds: 220);
  Future<void>? _future;
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<PinnedChatsSectionState> _pinnedSectionKey = GlobalKey<PinnedChatsSectionState>();
  final ValueNotifier<bool> _isEditingPinsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSavingPinsNotifier = ValueNotifier(false);
  bool _isSearchVisible = true;
  late final AnimationController _searchBarController;
  late final Animation<double> _searchBarAnimation;
  String _searchQuery = '';

  bool _showTopics = false;
  final GlobalKey _activeCallKey = GlobalKey();
  Rect? _lastReportedDockRect;

  late final ScrollController _chatsController;

  final _isOpenNotifier = ValueNotifier(false);

  Future<void> createNewFolder(BuildContext context) {
    final messengerCubit = context.read<MessengerCubit>();
    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: messengerCubit,
        child: BlocBuilder<MessengerCubit, MessengerState>(
          builder: (context, state) => CreateFolderDialog(
            isSaving: state.isFolderSaving,
            onSubmit: (folder) async {
              await context.read<MessengerCubit>().addFolder(folder);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> editFolder(BuildContext context, FolderEntity folder) {
    final messengerCubit = context.read<MessengerCubit>();
    context.pop();
    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: messengerCubit,
        child: BlocBuilder<MessengerCubit, MessengerState>(
          builder: (context, state) => UpdateFolderDialog(
            initial: folder,
            isSaving: state.isFolderSaving,
            onUpdate: (updated) async {
              await context.read<MessengerCubit>().updateFolder(updated);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<MessengerCubit>().searchChats(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  Future<void> getInitialData() async {
    await Future.wait([
      context.read<MessengerCubit>().loadFolders(),
      context.read<MessengerCubit>().getInitialMessages(),
    ]);
    if (mounted) {
      unawaited(context.read<MessengerCubit>().lazyLoadAllMessages());
    }
  }

  void _checkUser() {
    if (context.read<MessengerCubit>().state.selfUser == null) {
      context.read<MessengerCubit>().getUser();
    }
  }

  void _reportCallDockRect() {
    final renderContext = _activeCallKey.currentContext;
    final renderObject = renderContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final Offset offset = renderObject.localToGlobal(Offset.zero);
    final Size size = renderObject.size;
    final Rect rect = offset & size;

    if (_lastReportedDockRect == rect) return;
    _lastReportedDockRect = rect;
    renderContext!.read<CallCubit>().updateDockRect(rect);
  }

  void _clearDockRectIfNeeded() {
    if (_lastReportedDockRect == null) return;
    _lastReportedDockRect = null;
    context.read<CallCubit>().updateDockRect(null);
  }

  @override
  void initState() {
    _checkUser();
    _future = getInitialData();
    _searchBarController = AnimationController(
      vsync: this,
      duration: _searchAnimationDuration,
      value: 1,
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _searchBarController.addListener(() => setState(() {}));
    _chatsController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _searchController.dispose();
    _chatsController.dispose();
    _isEditingPinsNotifier.dispose();
    _isSavingPinsNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await context.read<MessengerCubit>().getUnreadMessages();
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ScreenSize screenSize = currentSize(context);
    final bool isLargeScreen = screenSize > ScreenSize.tablet;
    final bool isTabletOrSmaller = !isLargeScreen;
    final double searchVisibility = _searchBarAnimation.value;

    final EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: isTabletOrSmaller ? 20 : 8).copyWith(
      top: isTabletOrSmaller ? 20 : 0,
      bottom: 20,
    );

    return BlocListener<OrganizationsCubit, OrganizationsState>(
      listenWhen: (previous, current) => previous.selectedOrganizationId != current.selectedOrganizationId,
      listener: (context, state) {
        context.read<MessengerCubit>().resetState();
        context.read<MessengerCubit>().searchChats('');
        _pinnedSectionKey.currentState?.cancelEditing();
        _isEditingPinsNotifier.value = false;
        _isSavingPinsNotifier.value = false;
        setState(() {
          _searchQuery = '';
          _searchController.clear();
          _future = getInitialData();
        });
        unawaited(
          Future.wait([
            context.read<RealTimeCubit>().ensureConnection(),
            context.read<MessengerCubit>().getUnreadMessages(),
          ]),
        );
      },
      child: FutureBuilder(
        future: _future ?? Future.value(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocBuilder<MessengerCubit, MessengerState>(
            builder: (context, state) {
              final List<ChatEntity> baseChats = state.filteredChatIds == null
                  ? state.chats
                  : state.chats.where((chat) => state.filteredChatIds!.contains(chat.id)).toList();
              final List<ChatEntity> visibleChats = state.filteredChats ?? baseChats;

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isLargeScreen)
                    MessengerFolderRail(
                      folders: state.folders,
                      selectedFolderIndex: state.selectedFolderIndex,
                      onSelectFolder: (index) => context.read<MessengerCubit>().selectFolder(index),
                      onCreateFolder: () => createNewFolder(context),
                      onEditFolder: (folder) => editFolder(context, folder),
                      onOrderPinning: (index) => _handleOrderPinning(context, index),
                      onDeleteFolder: (folder) => _handleFolderDelete(context, folder),
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: isTabletOrSmaller ? MediaQuery.sizeOf(context).width : 315,
                    ),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: isTabletOrSmaller ? theme.colorScheme.background : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: _isEditingPinsNotifier,
                              builder: (context, isEditPinning, _) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable: _isSavingPinsNotifier,
                                  builder: (context, isSavingPinnedOrder, __) => MessengerAppBar(
                                    selectedChatLabel: state.selectedChat?.displayTitle,
                                    showTopics: _showTopics,
                                    onTapBack: () {
                                      setState(() {
                                        _showTopics = false;
                                      });
                                    },
                                    isLargeScreen: isLargeScreen,
                                    searchVisibility: searchVisibility,
                                    folders: state.folders,
                                    selectedFolderIndex: state.selectedFolderIndex,
                                    onSelectFolder: (index) => context.read<MessengerCubit>().selectFolder(index),
                                    onCreateFolder: () => unawaited(createNewFolder(context)),
                                    onEditFolder: (folder) async {
                                      await editFolder(context, folder);
                                    },
                                    onOrderPinning: _handleOrderPinning,
                                    onDeleteFolder: _handleFolderDelete,
                                    isEditPinning: isEditPinning,
                                    isSavingPinnedOrder: isSavingPinnedOrder,
                                    onStopEditingPins: _savePinnedChatOrder,
                                    showSearchField: _isSearchVisible,
                                    selfUserId: state.selfUser?.userId ?? -1,
                                    onSearchChanged: _onSearchChanged,
                                    onClearSearch: _clearSearch,
                                    searchController: _searchController,
                                    searchQuery: _searchQuery,
                                    isLoadingMore: !state.foundOldestMessage,
                                  ),
                                );
                              },
                            ),
                            if (visibleChats.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Text(context.t.folders.folderIsEmpty),
                                ),
                              ),
                            Expanded(
                              child: Stack(
                                children: [
                                  NotificationListener<UserScrollNotification>(
                                    onNotification: _onUserScroll,
                                    child: PinnedChatsSection(
                                      key: _pinnedSectionKey,
                                      visibleChats: visibleChats,
                                      pinnedMeta: state.pinnedChats,
                                      listPadding: listPadding,
                                      chatsController: _chatsController,
                                      selectedChatId: state.selectedChat?.id,
                                      showTopics: _showTopics,
                                      folderUuid: state.selectedFolderIndex < state.folders.length
                                          ? state.folders[state.selectedFolderIndex].uuid
                                          : null,
                                      onChatTap: (chat) async {
                                        if (isTabletOrSmaller) {
                                          if (chat.type == ChatType.channel) {
                                            setState(() {
                                              _showTopics = !_showTopics;
                                            });
                                          } else {
                                            openChat(context, chat.dmIds?.toSet() ?? {});
                                          }
                                        } else {
                                          context.read<MessengerCubit>().selectChat(chat);
                                        }
                                      },
                                      onEditingChanged: (value) => _isEditingPinsNotifier.value = value,
                                      onSavingChanged: (value) => _isSavingPinsNotifier.value = value,
                                    ),
                                  ),
                                  ChatTopicsList(
                                    showTopics: _showTopics,
                                    isPending: state.selectedChat?.topics == null,
                                    selectedChat: state.selectedChat,
                                    listPadding: _isSearchVisible ? 350 : 300,
                                  ),
                                  Align(
                                    alignment: AlignmentGeometry.bottomCenter,
                                    child: Padding(
                                      padding: listPadding.copyWith(
                                        bottom: 0,
                                        top: 0,
                                      ),
                                      child: Container(
                                        height: 1,
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<CallCubit, CallState>(
                              builder: (context, callState) {
                                final String? chatTitle = state.selectedChat?.displayTitle;
                                final String titleText = (chatTitle?.isNotEmpty ?? false)
                                    ? context.t.call.activeCallIn(name: chatTitle!)
                                    : (callState.meetLocationName.isNotEmpty
                                          ? context.t.call.activeCallIn(name: callState.meetLocationName)
                                          : context.t.call.activeCall);

                                return ActiveCallPanel(
                                  callState: callState,
                                  titleText: titleText,
                                  activeCallKey: _activeCallKey,
                                  onRestoreCall: context.read<CallCubit>().restoreCall,
                                  onReportDockRect: _reportCallDockRect,
                                  onClearDockRect: _clearDockRectIfNeeded,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isLargeScreen) ...[
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state.selectedChat?.dmIds != null) {
                            return Chat(
                              key: ObjectKey(
                                state.selectedChat!.id,
                              ),
                              userIds: state.selectedChat!.dmIds!,
                              unreadMessagesCount: state.selectedChat?.unreadMessages.length,
                              leadingOnPressed: () => _isOpenNotifier.value = !_isOpenNotifier.value,
                            );
                          }
                          if (state.selectedChat?.streamId != null) {
                            return ChannelChat(
                              key: ObjectKey(
                                state.selectedChat!.id,
                              ),
                              channelId: state.selectedChat!.streamId!,
                              topicName: state.selectedTopic,
                              unreadMessagesCount: state.selectedChat?.unreadMessages.length,
                              leadingOnPressed: () => _isOpenNotifier.value = !_isOpenNotifier.value,
                            );
                          }
                          return Center(child: Text(context.t.selectAnyChat));
                        },
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    ValueListenableBuilder(
                      valueListenable: _isOpenNotifier,
                      builder: (context, value, _) {
                        if (state.selectedChat?.dmIds != null || state.selectedChat?.streamId != null) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: value ? 315 : 0,
                            child: InfoPanel(
                              isChannel: state.selectedChat?.streamId != null,
                              onClose: () => _isOpenNotifier.value = false,
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification.direction == ScrollDirection.reverse && _isSearchVisible) {
      setState(() => _isSearchVisible = false);
      _searchBarController.reverse();
    } else if (notification.direction == ScrollDirection.forward && !_isSearchVisible) {
      setState(() => _isSearchVisible = true);
      _searchBarController.forward();
    }
    return false;
  }

  void _handleOrderPinning(BuildContext popupContext, int index) {
    popupContext.pop();
    popupContext.read<MessengerCubit>().selectFolder(index);
    _pinnedSectionKey.currentState?.enterEditMode();
  }

  void _savePinnedChatOrder() {
    final saveFuture = _pinnedSectionKey.currentState?.savePinnedChatOrder();
    if (saveFuture != null) {
      unawaited(saveFuture);
    }
  }

  Future<void> _handleFolderDelete(BuildContext popupContext, FolderEntity folder) async {
    popupContext.pop();
    final messengerCubit = popupContext.read<MessengerCubit>();
    await showDialog<void>(
      context: popupContext,
      builder: (dialogContext) => BlocProvider.value(
        value: messengerCubit,
        child: BlocBuilder<MessengerCubit, MessengerState>(
          builder: (ctx, state) {
            final bool isDeleting = state.isFolderDeleting;
            return AlertDialog(
              title: Text(popupContext.t.folders.deleteConfirmTitle),
              content: Text(
                popupContext.t.folders.deleteConfirmText(
                  folderName: folder.title ?? '',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(popupContext.t.folders.cancel),
                ),
                FilledButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          await ctx.read<MessengerCubit>().deleteFolder(folder);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(popupContext.t.folders.delete),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
