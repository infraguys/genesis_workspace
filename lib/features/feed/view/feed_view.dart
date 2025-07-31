import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/messages_list.dart';
import 'package:genesis_workspace/features/feed/bloc/feed_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _MixedFeedViewState();
}

class _MixedFeedViewState extends State<FeedView> {
  late final Future _future;

  @override
  void didChangeDependencies() {
    _future = context.read<FeedCubit>().getMessages();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.t.navBar.feed),
            backgroundColor: theme.colorScheme.inversePrimary,
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(child: Text("Some error...."));
                }
              }
              return MessagesList(messages: state.messages, showTopic: true);
            },
          ),
        );
      },
    );
  }
}
