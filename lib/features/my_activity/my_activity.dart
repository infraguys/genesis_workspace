import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/messenger/view/my_activity_items.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MyActivity extends StatelessWidget {
  const MyActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.t.myActivity,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Assets.icons.menu.svg(
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: const MyActivityItems(),
      ),
    );
  }
}
