import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/palettes/palette.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    return Row(
      crossAxisAlignment: .center,
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColors.text30,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
