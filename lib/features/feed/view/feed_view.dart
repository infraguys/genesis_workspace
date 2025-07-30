import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _MixedFeedViewState();
}

class _MixedFeedViewState extends State<FeedView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.navBar.feed),
        backgroundColor: theme.colorScheme.inversePrimary,
        centerTitle: true,
      ),
    );
  }
}
