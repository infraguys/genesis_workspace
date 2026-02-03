import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessagesSelectAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MessagesSelectAppBar({
    super.key,
    required this.selectedCount,
  });

  final int selectedCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    return AppBar(
      primary: isTabletOrSmaller,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Text(
        context.t.selectedCount(n: selectedCount),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            context.read<MessagesSelectCubit>().clearForwardMessages();
          },
          label: Text(context.t.general.cancel),
          icon: const Icon(Icons.cancel_outlined),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}
