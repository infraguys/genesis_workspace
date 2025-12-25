import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/topic_title.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ChannelAppBarTitle extends StatelessWidget {
  const ChannelAppBarTitle({
    super.key,
    required this.topicName,
    required this.channelName,
    required this.count,
    required this.onTap,
  });

  final String channelName;
  final String? topicName;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: isTabletOrSmaller
            ? _MobileTitle(channelName: channelName, topicName: topicName, count: count)
            : _Desktop(channelName: channelName, topicName: topicName, count: count),
      ),
    );
  }
}

class _MobileTitle extends StatelessWidget {
  const _MobileTitle({
    super.key, //ignore:unused_element_parameter
    required this.channelName,
    required this.count,
    this.topicName,
  });

  final String channelName;
  final String? topicName;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    final textColors = Theme.of(context).extension<TextColors>()!;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          channelName,
          style: textTheme.labelLarge?.copyWith(fontSize: isTabletOrSmaller ? 14 : 16),
        ),
        TopicTitle(topicName: topicName),
        SizedBox(height: 4.0),
        Text(
          context.t.group.membersCount(count: count),
          style: textTheme.bodySmall?.copyWith(color: textColors.text30),
        ),
      ],
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop({
    super.key, //ignore:unused_element_parameter
    required this.channelName,
    this.topicName,
    required this.count,
  });

  final String channelName;
  final String? topicName;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    final textColors = Theme.of(context).extension<TextColors>()!;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .start,
          mainAxisSize: .min,
          spacing: 12.0,
          children: [
            Text(
              channelName,
              style: textTheme.labelLarge?.copyWith(fontSize: isTabletOrSmaller ? 14 : 16),
            ),
            TopicTitle(topicName: topicName),
          ],
        ),
        Text(
          context.t.group.membersCount(count: count),
          style: textTheme.bodySmall?.copyWith(
            color: textColors.text30,
          ),
        ),
      ],
    );
  }
}
