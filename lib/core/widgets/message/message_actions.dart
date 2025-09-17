import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageActions extends StatelessWidget {
  final VoidCallback? onTapStarred;
  final VoidCallback? onTapDelete;
  final Function()? onTapQuote;
  final bool isStarred;
  final bool isMyMessage;
  final VoidCallback? onTapEdit;
  const MessageActions({
    super.key,
    required this.onTapStarred,
    required this.onTapQuote,
    required this.isStarred,
    required this.isMyMessage,
    required this.onTapDelete,
    this.onTapEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: context.t.messageActions.star,
          child: IconButton(
            onPressed: onTapStarred,
            icon: Icon(
              isStarred ? Icons.star : Icons.star_border,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Tooltip(
          message: context.t.messageActions.quote,
          child: IconButton(
            onPressed: onTapQuote,
            icon: Icon(Icons.format_quote, color: theme.colorScheme.primary),
          ),
        ),
        if (isMyMessage)
          Tooltip(
            message: context.t.messageActions.delete,
            child: IconButton(
              onPressed: onTapDelete,
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
            ),
          ),
        if (isMyMessage)
          IconButton(
            tooltip: 'Edit',
            onPressed: onTapEdit,
            icon: Icon(Icons.edit, color: theme.colorScheme.onSurface),
          ),
      ],
    );
  }
}
