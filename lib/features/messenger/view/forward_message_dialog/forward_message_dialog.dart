import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/widgets/app_progress_indicator.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/forward_message_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

part './dialog_chat_item.dart';
part './dialog_topic_item.dart';

class ForwardMessageDialog extends StatefulWidget {
  const ForwardMessageDialog({super.key, required this.message});

  final MessageEntity message;

  @override
  State<ForwardMessageDialog> createState() => _ForwardMessageDialogState();
}

class _ForwardMessageDialogState extends State<ForwardMessageDialog> {
  final _searchController = TextEditingController();
  final _tabsScroll = ScrollController();
  late final ForwardMessageCubit forwardMessageCubit;
  late final MessengerCubit messengerCubit;
  final _selectedFolderIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    messengerCubit = context.read<MessengerCubit>();
    forwardMessageCubit = context.read<ForwardMessageCubit>();
    _selectedFolderIndex.value = messengerCubit.state.selectedFolderIndex;
    forwardMessageCubit.applyChatFilter(_folderFilteredChats(messengerCubit.state));
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    forwardMessageCubit.applyChatFilter(_folderFilteredChats(messengerCubit.state), query: query);
  }

  List<ChatEntity> _folderFilteredChats(MessengerState state) {
    if (_selectedFolderIndex.value <= 0 || _selectedFolderIndex.value >= state.folders.length) {
      return state.chats;
    }
    final ids = state.folders[_selectedFolderIndex.value].folderItems;
    return state.chats.where((chat) => ids.contains(chat.id)).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = TextTheme.of(context);
    return Dialog(
      child: SizedBox(
        width: 400,
        height: 660,
        child: Padding(
          padding: const .symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Padding(
                padding: const .fromLTRB(12, 0, 12, 12),
                child: Text(
                  context.t.contextMenu.forward,
                  style: textTheme.titleMedium,
                  textAlign: .start,
                ),
              ),
              Padding(
                padding: const .symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    suffixIcon: Padding(
                      padding: const .only(right: 8.0),
                      child: Assets.icons.search.svg(
                        width: 28,
                        height: 28,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    hintText: context.t.search,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<MessengerCubit, MessengerState>(
                listener: (context, state) {
                  if (_selectedFolderIndex.value >= state.folders.length) {
                    _selectedFolderIndex.value = 0;
                  }
                  final query = _searchController.text.trim().toLowerCase();
                  forwardMessageCubit.applyChatFilter(_folderFilteredChats(state), query: query);
                },
                builder: (context, state) {
                  return Padding(
                    padding: const .symmetric(horizontal: 0.0),
                    child: ValueListenableBuilder(
                      valueListenable: _selectedFolderIndex,
                      builder: (context, value, _) {
                        return DefaultTabController(
                          initialIndex: value,
                          length: state.folders.length,
                          child: Listener(
                            onPointerSignal: (signal) {
                              if (signal is PointerScrollEvent && _tabsScroll.hasClients) {
                                final delta = signal.scrollDelta.dx != 0 ? signal.scrollDelta.dx : signal.scrollDelta.dy;
                                final next = (_tabsScroll.offset + delta).clamp(0.0, _tabsScroll.position.maxScrollExtent);
                                _tabsScroll.jumpTo(next);
                              }
                            },
                            child: SizedBox(
                              height: kTextTabBarHeight,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 1,
                                      color: theme.dividerColor.withValues(alpha: .10),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _tabsScroll,
                                      child: TabBar.secondary(
                                        onTap: (value) {
                                          if (_selectedFolderIndex.value == value) return;
                                          _selectedFolderIndex.value = value;
                                          final query = _searchController.text.trim().toLowerCase();
                                          forwardMessageCubit.applyChatFilter(
                                            _folderFilteredChats(messengerCubit.state),
                                            query: query,
                                          );
                                        },
                                        dividerColor: Colors.transparent,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        isScrollable: true,
                                        tabAlignment: .start,
                                        tabs: state.folders.indexed.map(
                                          (it) {
                                            final index = it.$1;
                                            final folder = it.$2;
                                            final title = index == 0 ? context.t.folders.all : folder.title;
                                            return Tab(text: title);
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              BlocBuilder<ForwardMessageCubit, ForwardMessageState>(
                builder: (context, state) {
                  if (state is! ForwardMessageSuccess) {
                    return AppProgressIndicator();
                  }
                  final chats = state.chats;
                  return Expanded(
                    child: Padding(
                      padding: const .all(12.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: .10)),
                          borderRadius: .circular(12),
                        ),
                        child: Padding(
                          padding: const .symmetric(vertical: 2.0),
                          child: ListView.separated(
                            padding: const .symmetric(horizontal: 8.0, vertical: 6.0),
                            itemCount: chats.length,
                            separatorBuilder: (_, _) => SizedBox(height: 4),
                            // controller: controller,
                            itemBuilder: (context, index) {
                              final chat = chats[index];
                              return _DialogChatItem(
                                key: ValueKey(chat.id),
                                chat: chat,
                                showTopics: true,
                                messageId: widget.message.id,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const .symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: .end,
                  spacing: 8.0,
                  children: [
                    TextButton(
                      onPressed: context.pop,
                      child: Text(context.t.groupChat.createDialog.cancel),
                    ),
                    // FilledButton(
                    //   onPressed: _selectedIds.isNotEmpty ? () => widget.onCreate(_selectedIds) : null,
                    //   child: Text(context.t.groupChat.createDialog.create),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
