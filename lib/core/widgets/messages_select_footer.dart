import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessagesSelectFooter extends StatelessWidget {
  final int count;
  final VoidCallback onForward;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  const MessagesSelectFooter({
    super.key,
    required this.count,
    required this.onForward,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Divider(
            color: theme.dividerColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: count == 0 ? null : onForward,
                      iconAlignment: .start,
                      icon: Assets.icons.forwardIcon.svg(
                        colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, .srcIn),
                      ),
                      label: Text(
                        context.t.contextMenu.forwardCount(
                          n: count,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: count == 0 ? null : onReply,
                      iconAlignment: .start,
                      icon: Assets.icons.replyIcon.svg(
                        colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, .srcIn),
                      ),
                      label: Text(
                        context.t.contextMenu.replyCount(
                          n: count,
                        ),
                      ),
                    ),
                    if (!isTabletOrSmaller) ...[
                      ElevatedButton.icon(
                        onPressed: count == 0 ? null : onDelete,
                        icon: Assets.icons.deleteIcon.svg(
                          colorFilter: ColorFilter.mode(theme.colorScheme.onError, .srcIn),
                        ),
                        label: Text(
                          context.t.contextMenu.delete,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
                isTabletOrSmaller
                    ? IconButton(
                        onPressed: count == 0 ? null : onDelete,
                        icon: Assets.icons.deleteIcon.svg(
                          colorFilter: ColorFilter.mode(theme.colorScheme.onError, .srcIn),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                        ),
                      )
                    : OutlinedButton.icon(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          context.read<MessagesSelectCubit>().clearForwardMessages();
                        },
                        label: Text(
                          context.t.general.cancel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
