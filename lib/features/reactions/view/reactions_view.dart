import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/reactions/bloc/reactions_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ReactionsView extends StatefulWidget {
  const ReactionsView({super.key});

  @override
  State<ReactionsView> createState() => _ReactionsViewState();
}

class _ReactionsViewState extends State<ReactionsView> {
  late final int _myUserId;
  late final Future _future;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _myUserId = context.read<ProfileCubit>().state.user?.userId ?? 0;
    _future = context.read<ReactionsCubit>().getMessages(_myUserId);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReactionsCubit, ReactionsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(title: context.t.reactions.title),
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (state.messages.isEmpty) {
                return Center(child: Text(context.t.reactions.noReactions));
              }
              return MessagesList(
                controller: _scrollController,
                messages: state.messages,
                isLoadingMore: state.isLoadingMore,
                myUserId: _myUserId,
                loadMore: () {
                  context.read<ReactionsCubit>().loadMoreMessages(_myUserId);
                },
              );
            },
          ),
        );
      },
    );
  }
}
