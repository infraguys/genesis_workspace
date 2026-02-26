import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/core/widgets/animated_overlay.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messenger/entities/pinned_chat_order_update.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/features/drafts/drafts.dart';
import 'package:genesis_workspace/features/mentions/mentions.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/chat_topics_list.dart';
import 'package:genesis_workspace/features/messenger/view/create_chat/create_chat_menu.dart';
import 'package:genesis_workspace/features/messenger/view/create_folder_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/info_panel.dart';
import 'package:genesis_workspace/features/messenger/view/messenger_app_bar.dart';
import 'package:genesis_workspace/features/messenger/view/my_activity_desktop_section.dart';
import 'package:genesis_workspace/features/messenger/view/update_folder_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/active_call_panel.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/messenger_folder_rail.dart';
import 'package:genesis_workspace/features/messenger/view/widgets/pinned_chats_section.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/reactions/reactions.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/starred/starred.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class MessengerView extends StatefulWidget {
  const MessengerView({super.key});

  @override
  State<MessengerView> createState() => _MessengerViewState();
}

class _MessengerViewState extends State<MessengerView>
    with SingleTickerProviderStateMixin, OpenChatMixin, WidgetsBindingObserver {
  static const _searchAnimationDuration = Duration(milliseconds: 220);
  Future<void>? _future;
  final _searchController = TextEditingController();
  bool _isSearchVisible = true;
  late final AnimationController _searchBarController;
  late final Animation<double> _searchBarAnimation;
  String _searchQuery = '';

  bool _isEditPinning = false;
  bool _isSavingPins = false;
  List<PinnedChatOrderUpdate> _updatedPinnedChats = [];

  bool _showTopics = false;
  final _activeCallKey = GlobalKey();
  Rect? _lastReportedDockRect;

  OverlayEntry? _createChatMenuEntry;

  late final ScrollController _chatsController;

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
      context.read<DraftsCubit>().getDrafts(),
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

  void _applySortingPreferences() {
    final settings = context.read<SettingsCubit>().state;
    context.read<MessengerCubit>().applyChatSortingPreferences(
      prioritizePersonalUnread: settings.prioritizePersonalUnread,
      prioritizeUnmutedUnreadChannels: settings.prioritizeUnmutedUnreadChannels,
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
    setState(() {
      _isEditPinning = true;
    });
  }

  Future<void> savePinnedChatOrder(String folderUuid, List<PinnedChatOrderUpdate> chats) async {
    setState(() {
      _isSavingPins = true;
    });
    try {
      await context.read<MessengerCubit>().reorderPinnedChats(
        folderUuid: folderUuid,
        updates: chats,
      );
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      setState(() {
        _isEditPinning = false;
        _isSavingPins = false;
        _updatedPinnedChats = [];
      });
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

  void _closeCreateChatMenu() {
    _createChatMenuEntry?.remove();
    _createChatMenuEntry = null;
  }

  void _openCreateChatMenu(Offset globalPosition, {required int selfUserId}) {
    _closeCreateChatMenu();

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }

    final localInOverlay = overlayBox.globalToLocal(globalPosition);

    _createChatMenuEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.sizeOf(context);
        const padding = 8.0;
        const menuWidth = 260.0;
        const menuHeight = 160.0;

        final spaceBelow = screenSize.height - localInOverlay.dy - padding;
        final openDown = spaceBelow > menuHeight;

        final left = localInOverlay.dx.clamp(
          padding,
          screenSize.width - menuWidth - padding,
        );

        return AnimatedOverlay(
          left: left,
          top: openDown ? localInOverlay.dy : null,
          bottom: openDown ? null : (screenSize.height - localInOverlay.dy),
          alignment: openDown ? Alignment.topLeft : Alignment.bottomLeft,
          closeOverlay: _closeCreateChatMenu,
          child: Container(
            width: menuWidth,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: CreateChatMenu(
              selfUserId: selfUserId,
              onClose: _closeCreateChatMenu,
            ),
          ),
        );
      },
    );

    overlay.insert(_createChatMenuEntry!);
  }

  @override
  void initState() {
    final selectedOrganizationId = context.read<OrganizationsCubit>().state.selectedOrganizationId;
    if (selectedOrganizationId != null) {
      context.read<MessengerCubit>().syncSelectedOrganization(selectedOrganizationId);
    }
    _applySortingPreferences();
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
    _closeCreateChatMenu();
    _searchBarController.dispose();
    _searchController.dispose();
    _chatsController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await context.read<MessengerCubit>().getMessagesAfterLoseConnection();
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screenSize = currentSize(context);
    final isLargeScreen = screenSize > ScreenSize.tablet;
    final isTabletOrSmaller = !isLargeScreen;
    final searchVisibility = _searchBarAnimation.value;

    final EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: isTabletOrSmaller ? 12 : 8).copyWith(
      top: isTabletOrSmaller ? 20 : 0,
      bottom: 20,
    );

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.prioritizePersonalUnread != current.prioritizePersonalUnread ||
          previous.prioritizeUnmutedUnreadChannels != current.prioritizeUnmutedUnreadChannels,
      listener: (context, settingsState) {
        context.read<MessengerCubit>().applyChatSortingPreferences(
          prioritizePersonalUnread: settingsState.prioritizePersonalUnread,
          prioritizeUnmutedUnreadChannels: settingsState.prioritizeUnmutedUnreadChannels,
        );
      },
      child: BlocListener<OrganizationsCubit, OrganizationsState>(
        listenWhen: (previous, current) => previous.selectedOrganizationId != current.selectedOrganizationId,
        listener: (context, state) {
          context.read<MessengerCubit>().resetState(state.selectedOrganizationId ?? -1);
          context.read<MessengerCubit>().searchChats('');
          setState(() {
            _searchQuery = '';
            _searchController.clear();
            _future = getInitialData();
          });
          unawaited(
            Future.wait([
              context.read<RealTimeCubit>().ensureConnection(),
              context.read<MessengerCubit>().getUnreadMessages(),
              context.read<DraftsCubit>().getDrafts(),
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
                              MessengerAppBar(
                                selectedChatLabel: state.selectedChat?.displayTitle,
                                showTopics: _showTopics,
                                onTapBack: () {
                                  setState(() {
                                    _showTopics = false;
                                  });
                                  context.read<MessengerCubit>().unselectChat();
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
                                isEditPinning: _isEditPinning,
                                isSavingPinnedOrder: _isSavingPins,
                                onStopEditingPins: () {
                                  unawaited(
                                    savePinnedChatOrder(
                                      state.folders[state.selectedFolderIndex].uuid,
                                      _updatedPinnedChats,
                                    ),
                                  );
                                },
                                showSearchField: _isSearchVisible,
                                selfUserId: state.selfUser?.userId ?? -1,
                                onSearchChanged: _onSearchChanged,
                                onClearSearch: _clearSearch,
                                searchController: _searchController,
                                searchQuery: _searchQuery,
                                isLoadingMore: !state.foundOldestMessage,
                                onShowChats: (position) => _openCreateChatMenu(
                                  position,
                                  selfUserId: state.selfUser?.userId ?? -1,
                                ),
                              ),
                              if (!isTabletOrSmaller) ...[
                                const MyActivityDesktopSection(),
                                const SizedBox(height: 8),
                              ],
                              Expanded(
                                child: Stack(
                                  children: [
                                    NotificationListener<UserScrollNotification>(
                                      onNotification: _onUserScroll,
                                      child: PinnedChatsSection(
                                        visibleChats: visibleChats,
                                        pinnedMeta: state.pinnedChats,
                                        listPadding: listPadding,
                                        chatsController: _chatsController,
                                        selectedChatId: state.selectedChat?.id,
                                        showTopics: _showTopics,
                                        isEditPinning: _isEditPinning,
                                        folderUuid: state.selectedFolderIndex < state.folders.length
                                            ? state.folders[state.selectedFolderIndex].uuid
                                            : null,
                                        onChatTap: (chat) async {
                                          if (isTabletOrSmaller) {
                                            if (chat.type == ChatType.channel) {
                                              setState(() {
                                                _showTopics = true;
                                              });
                                            } else {
                                              openChat(
                                                context,
                                                chatId: chat.id,
                                                membersIds: chat.dmIds?.toSet() ?? {},
                                                messageId: chat.firstUnreadMessageId,
                                              );
                                            }
                                          } else {
                                            context.read<MessengerCubit>().selectChat(chat);
                                          }
                                        },
                                        onPinningSaved: (chats) {
                                          setState(() {
                                            _updatedPinnedChats = chats;
                                          });
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        transitionBuilder: (child, animation) {
                                          final offsetAnimation = Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: .zero,
                                          ).animate(animation);
                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                        child: (isTabletOrSmaller && _showTopics)
                                            ? ChatTopicsList(
                                                key: const ValueKey('topics_list'),
                                                isPending: state.selectedChat?.topics == null,
                                                selectedChat: state.selectedChat,
                                                listPadding: _isSearchVisible ? 350 : 300,
                                                onDismissed: () {
                                                  setState(() => _showTopics = false);
                                                },
                                              )
                                            : const SizedBox.shrink(key: ValueKey('topics_empty')),
                                      ),
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
                                    if (visibleChats.isEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: Center(
                                          child: Text(context.t.folders.folderIsEmpty),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              BlocBuilder<CallCubit, CallState>(
                                builder: (context, callState) {
                                  final String titleText = callState.meetLocationName.isNotEmpty
                                      ? context.t.call.activeCallIn(name: callState.meetLocationName)
                                      : context.t.call.activeCall;
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
                        child: BlocBuilder<InfoPanelCubit, InfoPanelState>(
                          builder: (context, panelState) {
                            switch (state.openedSection) {
                              case .chat:
                                if (state.usersIds.isNotEmpty && state.selectedChat == null) {
                                  return Chat(
                                    key: ObjectKey(state.usersIds),
                                    chatId: state.selectedChat?.id,
                                    userIds: state.usersIds.toList(),
                                    firstMessageId: state.selectedChat?.firstUnreadMessageId,
                                    focusedMessageId: state.focusedMessageId,
                                    leadingOnPressed: () {
                                      if (panelState.status != .closed) {
                                        context.read<InfoPanelCubit>().setInfoPanelState(.closed);
                                      } else {
                                        context.read<InfoPanelCubit>().setInfoPanelState(.dmInfo);
                                      }
                                    },
                                  );
                                }
                                if (state.selectedChat?.dmIds != null) {
                                  return Chat(
                                    key: ObjectKey(
                                      state.selectedChat!.id,
                                    ),
                                    chatId: state.selectedChat?.id,
                                    userIds: state.selectedChat!.dmIds!,
                                    firstMessageId: state.selectedChat?.firstUnreadMessageId,
                                    focusedMessageId: state.focusedMessageId,
                                    leadingOnPressed: () {
                                      if (panelState.status != .closed) {
                                        context.read<InfoPanelCubit>().setInfoPanelState(.closed);
                                      } else {
                                        context.read<InfoPanelCubit>().setInfoPanelState(.dmInfo);
                                      }
                                    },
                                  );
                                }
                                if (state.selectedChat?.streamId != null) {
                                  return ChannelChat(
                                    key: ObjectKey(
                                      state.selectedChat!.id,
                                    ),
                                    chatId: state.selectedChat!.id,
                                    channelId: state.selectedChat!.streamId!,
                                    topicName: state.selectedTopic,
                                    firstMessageId: state.selectedTopic != null
                                        ? state.selectedChat?.topicFirstUnreadMessageId(state.selectedTopic!)
                                        : state.selectedChat?.firstUnreadMessageId,
                                    focusedMessageId: state.focusedMessageId,
                                    leadingOnPressed: () {
                                      if (panelState.status != .closed) {
                                        context.read<InfoPanelCubit>().setInfoPanelState(.closed);
                                      } else {
                                        context.read<InfoPanelCubit>().setInfoPanelState(.channelInfo);
                                      }
                                    },
                                  );
                                }
                              case .starredMessages:
                                return Starred();
                              case .mentions:
                                return Mentions();
                              case .reactions:
                                return Reactions();
                              case .drafts:
                                return Drafts();
                              default:
                                return Center(child: Text(context.t.selectAnyChat));
                            }
                            return Center(child: Text(context.t.selectAnyChat));
                          },
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      BlocBuilder<InfoPanelCubit, InfoPanelState>(
                        builder: (context, panelState) {
                          if (state.selectedChat?.dmIds != null ||
                              state.selectedChat?.streamId != null ||
                              panelState.status == .profileInfo) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: panelState.status != .closed ? 315 : 0,
                              child: InfoPanel(
                                onClose: () {
                                  context.read<InfoPanelCubit>().setInfoPanelState(.closed);
                                },
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
      ),
    );
  }
}
