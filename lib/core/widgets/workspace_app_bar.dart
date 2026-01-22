import 'package:flutter/material.dart';

class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final PreferredSize? bottom;
  final bool centerTitle;

  const WorkspaceAppBar({super.key, required this.title, this.leading, this.bottom, this.centerTitle = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: title,
      backgroundColor: theme.colorScheme.surface,
      centerTitle: centerTitle,
      leading: leading,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
