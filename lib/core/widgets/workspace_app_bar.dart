import 'package:flutter/material.dart';

class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final PreferredSize? bottom;

  const WorkspaceAppBar({Key? key, required this.title, this.leading, this.bottom})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(title),
      backgroundColor: theme.colorScheme.inversePrimary,
      centerTitle: true,
      leading: leading,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
