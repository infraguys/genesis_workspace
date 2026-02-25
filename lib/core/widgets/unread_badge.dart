import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final bool isMuted;

  const UnreadBadge({super.key, required this.count, this.isMuted = false});

  String _formatCount(int value) => value >= 1000 ? '999+' : value.toString();

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final noticeColors = theme.extension<NoticeColors>()!;
    final TextStyle textStyle = theme.textTheme.labelSmall!.copyWith(
      color: noticeColors.onBadge,
      fontSize: 12,
    );

    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: isMuted ? noticeColors.noticeDisable : noticeColors.counterBadge,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(_formatCount(count), style: textStyle),
      ),
    );
  }
}
