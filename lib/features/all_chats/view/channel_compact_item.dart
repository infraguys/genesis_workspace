import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';

class ChannelCompactItem extends StatelessWidget {
  final ChannelEntity channel;
  final bool isPinned;
  final Widget? trailingOverride;

  const ChannelCompactItem({
    super.key,
    required this.channel,
    required this.isPinned,
    this.trailingOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle channelTextStyle = theme.textTheme.bodyLarge!;
    final Color channelColor = parseColor(channel.color);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(width: 3, height: 24, color: channelColor),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
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
                        '# ${channel.name}',
                        style: channelTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isPinned)
                        Icon(
                          Icons.push_pin,
                          size: 12,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      if (channel.isMuted)
                        Icon(
                          Icons.headset_off,
                          size: 12,
                          color: theme.colorScheme.outlineVariant,
                        ),
                    ],
                  ),
                  trailingOverride ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
