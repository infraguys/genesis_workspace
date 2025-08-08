import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/messages_list.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/feed/bloc/feed_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _MixedFeedViewState();
}

class _MixedFeedViewState extends State<FeedView> {
  late final UserEntity _myUser;
  late final Future _future;
  late final ScrollController _scrollController;

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !context.read<FeedCubit>().state.isLoadingMore) {
      context.read<FeedCubit>().loadMoreMessages();
    }
  }

  @override
  void didChangeDependencies() {
    _myUser = context.read<ProfileCubit>().state.user!;
    _scrollController = ScrollController()..addListener(_onScroll);
    _future = context.read<FeedCubit>().getMessages();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(title: context.t.feed),
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
              return MessagesList(
                controller: _scrollController,
                messages: state.messages,
                isLoadingMore: state.isLoadingMore,
                showTopic: true,
                myUserId: _myUser.userId,
              );
            },
          ),
        );
      },
    );
  }
}
