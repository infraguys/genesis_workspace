import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';

class ChannelItem extends StatelessWidget {
  final ChannelEntity channel;
  final int? selectedChannelId;
  final int index;
  final GlobalKey avatarContainerKey;
  const ChannelItem({
    super.key,
    required this.channel,
    this.selectedChannelId,
    required this.index,
    required this.avatarContainerKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      highlightColor: theme.colorScheme.primaryContainer,
      onTap: () async {
        context.read<ChannelsCubit>().selectChannelId(channel);
        if (currentSize(context) > ScreenSize.tablet) {
          context.read<ChannelsCubit>().openTopic(channel: channel);
        }
        await context.read<ChannelsCubit>().getChannelTopics(streamId: channel.streamId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: selectedChannelId == channel.streamId ? theme.colorScheme.primaryContainer : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              key: index == 0 ? avatarContainerKey : null,
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: parseColor(channel.color),
                child: Text(channel.name.characters.first.toUpperCase()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (channel.description.isNotEmpty)
                    Text(
                      channel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            Badge.count(
              count: channel.unreadMessages.length,
              isLabelVisible: channel.unreadMessages.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
