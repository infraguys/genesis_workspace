import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelDownExpandedItem extends StatefulWidget {
  final ChannelEntity channel;
  final VoidCallback? onTap;
  final void Function(TopicEntity topic)? onTopicTap;
  final Widget? trailingOverride;
  final bool isEditPinning;
  final bool isPinned;
  final int? pinnedChatId;

  const ChannelDownExpandedItem({
    super.key,
    required this.channel,
    this.onTap,
    this.onTopicTap,
    this.trailingOverride,
    this.isEditPinning = false,
    this.isPinned = false,
    this.pinnedChatId,
  });

  @override
  State<ChannelDownExpandedItem> createState() => _ChannelDownExpandedItemState();
}

class _ChannelDownExpandedItemState extends State<ChannelDownExpandedItem> {
  bool isExpanded = false;
  late final Color channelColor;

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeInOut;

  final popupKey = GlobalKey<CustomPopupState>();

  void _handleHeaderTap() {
    if (isExpanded == false) {
      setState(() => isExpanded = true);
      widget.onTap!();
    } else {
      setState(() {
        isExpanded = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    channelColor = parseColor(widget.channel.color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle channelTextStyle = theme.textTheme.bodyLarge!;
    final TextStyle topicTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final Widget content = Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _handleHeaderTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(width: 3, height: 24, color: channelColor),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: _animationDuration,
                    curve: _animationCurve,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Text(
                              '# ${widget.channel.name}',
                              style: channelTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.isPinned)
                              Icon(
                                Icons.push_pin,
                                size: 12,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            if (widget.channel.isMuted)
                              Icon(
                                Icons.headset_off,
                                size: 12,
                                color: theme.colorScheme.outlineVariant,
                              ),
                          ],
                        ),
                        widget.trailingOverride ??
                            UnreadBadge(
                              count: widget.channel.unreadMessages.length,
                              isMuted: widget.channel.isMuted,
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: _animationDuration,
            curve: _animationCurve,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Skeletonizer(
                      enabled: widget.channel.topics.isEmpty,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.channel.topics.isEmpty ? 3 : widget.channel.topics.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (widget.channel.topics.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text('• topic.name', style: topicTextStyle),
                            );
                          } else {
                            final TopicEntity topic = widget.channel.topics[index];
                            return InkWell(
                              onTap: () => widget.onTopicTap?.call(topic),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('• ${topic.name}', style: topicTextStyle),
                                    UnreadBadge(count: topic.unreadMessages.length),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const Divider(height: 1),
        ],
      ),
    );

    if (widget.isEditPinning) {
      return content;
    }

    return GestureDetector(
      onSecondaryTap: () => popupKey.currentState?.show(),
      child: CustomPopup(
        key: popupKey,
        anchorKey: popupKey,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.channel.isMuted
                    ? ListTile(
                        leading: const Icon(Icons.headset),
                        title: Text(context.t.channel.unmuteChannel),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await context.read<ChannelsCubit>().unmuteChannel(widget.channel);
                        },
                      )
                    : ListTile(
                        leading: const Icon(Icons.headset_off),
                        title: Text(context.t.channel.muteChannel),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await context.read<ChannelsCubit>().muteChannel(widget.channel);
                        },
                      ),
                if (widget.isPinned)
                  ListTile(
                    leading: const Icon(Icons.push_pin_outlined),
                    title: Text(context.t.chat.unpinChat),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final int? id = widget.pinnedChatId;
                      if (id != null) {
                        await context.read<AllChatsCubit>().unpinChat(id);
                      }
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.push_pin),
                    title: Text(context.t.chat.pinChat),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await context.read<AllChatsCubit>().pinChat(
                        chatId: widget.channel.streamId,
                        type: PinnedChatType.channel,
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: Text(context.t.folders.addToFolder),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await context.read<AllChatsCubit>().loadFolders();
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (_) => SelectFoldersDialog(
                          loadSelectedFolderIds: () => context
                              .read<AllChatsCubit>()
                              .getFolderIdsForChannel(widget.channel.streamId),
                          onSave: (ids) => context.read<AllChatsCubit>().setFoldersForChannel(
                            widget.channel.streamId,
                            ids,
                          ),
                          folders: context.read<AllChatsCubit>().state.folders,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        child: content,
      ),
    );
  }
}
