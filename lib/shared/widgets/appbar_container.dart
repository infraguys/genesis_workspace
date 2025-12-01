import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';

class AppBarContainer extends StatelessWidget implements PreferredSizeWidget {
  const AppBarContainer({super.key, required this.appBar});

  final PreferredSizeWidget appBar;

  @override
  Size get preferredSize => const Size.fromHeight(76);



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;

    return Column(
      children: [
        if (Platform.isMacOS && isTabletOrSmaller) Container(
          height: 20.0,
          width: double.infinity,
          color: theme.colorScheme.surface,
        ),
        appBar,
      ],
    );
  }
}
