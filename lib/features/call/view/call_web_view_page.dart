import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/call/view/call_web_view.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CallWebViewPage extends StatelessWidget {
  const CallWebViewPage({
    super.key,
    required this.meetingLink,
  });

  final String meetingLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.call.title),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CallWebView(
          meetingLink: meetingLink,
          title: context.t.call.title,
          showHeader: false,
          onClose: () => context.pop(),
          onMinimize: () {},
        ),
      ),
    );
  }
}
