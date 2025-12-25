import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';

class TopicTitle extends StatelessWidget {
  const TopicTitle({super.key, this.topicName});

  final String? topicName;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    final textColors = Theme.of(context).extension<TextColors>()!;
    return topicName == null
        ? SizedBox.shrink()
        : Row(
            spacing: 12.0,
            children: [
              Container(
                height: 16,
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: .circular(16),
                ),
              ),
              Text(
                '# $topicName',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: isTabletOrSmaller ? 14 : null,
                  color: textColors.text30,
                ),
              ),
            ],
          );
  }
}
