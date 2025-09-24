import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/channel_down_expanded_item.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';

class AllChatsChannels extends StatefulWidget {
  final Set<int>? filteredChannels;
  const AllChatsChannels({super.key, required this.filteredChannels});

  @override
  State<AllChatsChannels> createState() => _AllChatsChannelsState();
}

class _AllChatsChannelsState extends State<AllChatsChannels> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsCubit, ChannelsState>(
      builder: (context, channelsState) {
        inspect(channelsState);
        final channels = widget.filteredChannels == null
            ? channelsState.channels
            : channelsState.channels
                  .where((ch) => widget.filteredChannels!.contains(ch.streamId))
                  .toList(growable: false);
        if (channels.isEmpty) {
          return const SizedBox.shrink();
        }
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.t.navBar.channels,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: channels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    final popupKey = GlobalKey<CustomPopupState>();
                    return CustomPopup(
                      key: popupKey,
                      position: PopupPosition.auto,
                      contentPadding: EdgeInsets.zero,
                      isLongPress: true,
                      content: Container(
                        width: 240,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                          boxShadow: kElevationToShadow[3],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: const Icon(Icons.folder_open),
                            title: Text(context.t.folders.addToFolder),
                            onTap: () async {
                              // popupKey.currentState?.hide();
                              context.pop();
                              await context.read<AllChatsCubit>().loadFolders();
                              await showDialog(
                                context: context,
                                builder: (_) => SelectFoldersDialog(
                                  loadSelectedFolderIds: () => context
                                      .read<AllChatsCubit>()
                                      .getFolderIdsForChannel(channel.streamId),
                                  onSave: (ids) => context
                                      .read<AllChatsCubit>()
                                      .setFoldersForChannel(channel.streamId, ids),
                                  folders: context.read<AllChatsCubit>().state.folders,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onSecondaryTap: () => popupKey.currentState?.show(),
                        child: ChannelDownExpandedItem(
                          key: ValueKey(channel.streamId),
                          channel: channel,
                          onTap: () async {
                            context.read<AllChatsCubit>().selectChannel(channel: channel);
                            await context.read<ChannelsCubit>().getChannelTopics(
                              streamId: channel.streamId,
                            );
                          },
                          onTopicTap: (topic) {
                            context.read<AllChatsCubit>().selectChannel(
                              channel: channel,
                              topic: topic,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
