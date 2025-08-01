import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class InboxView extends StatelessWidget {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: WorkspaceAppBar(title: context.t.inbox));
  }
}
