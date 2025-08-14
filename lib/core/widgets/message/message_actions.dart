import 'package:flutter/material.dart';

class MessageActions extends StatelessWidget {
  final VoidCallback? onTapStarred;
  final bool isStarred;
  const MessageActions({super.key, required this.onTapStarred, required this.isStarred});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTapStarred,
          icon: Icon(isStarred ? Icons.star : Icons.star_border, color: theme.colorScheme.primary),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.edit, color: theme.colorScheme.primary),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.copy, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }
}
