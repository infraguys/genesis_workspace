import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/messenger/view/my_activity_items.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MyActivity extends StatelessWidget {
  const MyActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WorkspaceAppBar(
        title: Text(context.t.myActivity),
      ),
      body: SafeArea(
        child: const MyActivityItems(),
      ),
    );
  }
}
