import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final bool isMuted;

  const UnreadBadge({super.key, required this.count, this.isMuted = false});

  String _formatCount(int value) => value > 999 ? '999+' : value.toString();

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle textStyle = Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: colorScheme.onPrimary);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isMuted ? colorScheme.outlineVariant : colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(_formatCount(count), style: textStyle),
    );
  }
}
