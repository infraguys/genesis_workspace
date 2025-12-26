import 'package:flutter/material.dart';

class TopicSeparator extends StatelessWidget {
  final String topic;

  const TopicSeparator({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color dividerColor = theme.colorScheme.surface;

    return Row(
      spacing: 16.0,
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Text(
          '# $topic',
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: 12.0,
            color: theme.colorScheme.primary,
            fontWeight: .w400,
          ),
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }
}