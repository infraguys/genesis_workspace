import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/message/message_item.dart';
import 'package:genesis_workspace/core/widgets/message/messages_list.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/reactions/bloc/reactions_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    _myUserId = context.read<ProfileCubit>().state.user?.userId ?? -1;
    _future = context.read<ReactionsCubit>().getMessages(_myUserId);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReactionsCubit, ReactionsState>(
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
                    color: Color(0xff58a333),
                  ),
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  context.t.reactions.title,
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
                        myUserId: _myUserId,
                        onTapQuote: (_, {quote}) {},
                        onTapEditMessage: (_) {},
                      );
                    },
                  ),
                );
              }
              if (state.messages.isEmpty) {
                return Center(child: Text(context.t.reactions.noReactions));
              }
              return MessagesList(
                controller: _scrollController,
                messages: state.messages,
                isLoadingMore: state.isLoadingMore,
                myUserId: _myUserId,
                loadMorePrev: () async {
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
