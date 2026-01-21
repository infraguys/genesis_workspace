import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/mentions/bloc/mentions_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
          appBar: WorkspaceAppBar(
            title: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xfff0ca4c),
                  ),
                  child: Icon(
                    Icons.alternate_email,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  context.t.mentions.title,
                ),
              ],
            ),
            centerTitle: false,
          ),
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    itemCount: 20,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ).copyWith(bottom: 12),
                    itemBuilder: (context, index) {
                      return MessageItem(
                        isMyMessage: index % 5 == 0,
                        message: MessageEntity.fake(),
                        isSkeleton: true,
                        messageOrder: MessageUIOrder.single,
                        myUserId: myUserId ?? -1,
                        onTapQuote: (_) {},
                        onTapEditMessage: (_) {},
                      );
                    },
                  ),
                );
              }
              if (state.messages.isEmpty) {
                return Center(child: Text(context.t.mentions.noMentions));
              }
              return MessagesList(
                controller: _scrollController,
                messages: state.messages,
                isLoadingMore: state.isLoadingMore,
                myUserId: myUserId ?? -1,
                loadMore: context.read<MentionsCubit>().loadMoreMessages,
                showTopic: true,
              );
            },
          ),
        );
      },
    );
  }
}
