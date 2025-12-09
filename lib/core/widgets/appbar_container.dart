import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info_io.dart';

class AppBarContainer extends StatelessWidget implements PreferredSizeWidget {
  const AppBarContainer({super.key, required this.appBar});

  final PreferredSizeWidget appBar;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  bool get isMacOsSafe {
    return platformInfo.isMacos;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;

    return Column(
      mainAxisSize: .min,
      children: [
        if (isMacOsSafe && isTabletOrSmaller)
          Container(
            height: 20.0,
            width: double.infinity,
            color: theme.colorScheme.surface,
          ),
        appBar,
      ],
    );
  }
}
