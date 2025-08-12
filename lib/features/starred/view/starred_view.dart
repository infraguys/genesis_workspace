import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/messages_list.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/starred/bloc/starred_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class StarredView extends StatefulWidget {
  const StarredView({super.key});

  @override
  State<StarredView> createState() => _StarredViewState();
}

class _StarredViewState extends State<StarredView> {
  late final Future _future;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _future = context.read<StarredCubit>().getMessages();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = context.select<ProfileCubit, int?>((cubit) => cubit.state.user?.userId);
    return BlocBuilder<StarredCubit, StarredState>(
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(title: context.t.starred.title),
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (state.messages.isEmpty) {
                return Center(child: Text(context.t.starred.noStarred));
              }
              return MessagesList(
                controller: _scrollController,
                messages: state.messages,
                isLoadingMore: state.isLoadingMore,
                myUserId: myUserId ?? 0,
                loadMore: context.read<StarredCubit>().loadMoreMessages,
              );
            },
          ),
        );
      },
    );
  }
}
