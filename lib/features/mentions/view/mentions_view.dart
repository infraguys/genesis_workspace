import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/mentions/bloc/mentions_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MentionsView extends StatefulWidget {
  const MentionsView({super.key});

  @override
  State<MentionsView> createState() => _MentionsViewState();
}

class _MentionsViewState extends State<MentionsView> {
  late final Future _future;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _future = context.read<MentionsCubit>().getMessages();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = context.select<ProfileCubit, int?>((cubit) => cubit.state.user?.userId);

    return BlocBuilder<MentionsCubit, MentionsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(title: context.t.mentions.title),
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (state.messages.isEmpty) {
                return Center(child: Text(context.t.mentions.noMentions));
              }
              return MessagesList(
                controller: _scrollController,
                messages: state.messages,
                isLoadingMore: state.isLoadingMore,
                myUserId: myUserId ?? 0,
                loadMore: context.read<MentionsCubit>().loadMoreMessages,
              );
            },
          ),
        );
      },
    );
  }
}
