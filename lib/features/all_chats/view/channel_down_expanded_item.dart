import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelDownExpandedItem extends StatefulWidget {
  final ChannelEntity channel;
  final VoidCallback? onTap;
  final void Function(TopicEntity topic)? onTopicTap;

  const ChannelDownExpandedItem({super.key, required this.channel, this.onTap, this.onTopicTap});

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
    final TextStyle channelTextStyle = Theme.of(context).textTheme.bodyLarge!;
    final TextStyle topicTextStyle = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

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
            child: ListTile(
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
          ),
        ),
        child: Material(
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
                        child: Text(
                          '# ${widget.channel.name}',
                          style: channelTextStyle,
                          overflow: TextOverflow.ellipsis,
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
                            itemCount: widget.channel.topics.isEmpty
                                ? 3
                                : widget.channel.topics.length,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text('• ${topic.name}', style: topicTextStyle),
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
        ),
      ),
    );
  }
}
