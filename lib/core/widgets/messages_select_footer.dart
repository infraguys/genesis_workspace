import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessagesSelectFooter extends StatelessWidget {
  final int count;
  final VoidCallback onForward;
  final VoidCallback onReply;
  const MessagesSelectFooter({
    super.key,
    required this.count,
    required this.onForward,
    required this.onReply,
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
                    ElevatedButton(
                      onPressed: count == 0 ? null : onForward,
                      child: Text(
                        context.t.contextMenu.forwardCount(
                          n: count,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: count == 0 ? null : onReply,
                      child: Text(
                        context.t.contextMenu.replyCount(
                          n: count,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isTabletOrSmaller)
                  OutlinedButton(
                    onPressed: () {
                      context.read<MessagesSelectCubit>().setSelectMode(false);
                    },
                    child: Text(
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
