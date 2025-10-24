import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final bool isMuted;

  const UnreadBadge({super.key, required this.count, this.isMuted = false});

  String _formatCount(int value) => value >= 100 ? '99+' : value.toString();

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle textStyle = Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: AppColors.onBadge, fontSize: 12);

    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: isMuted ? colorScheme.outlineVariant : AppColors.counterBadge,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(_formatCount(count), style: textStyle),
      ),
    );
  }
}
