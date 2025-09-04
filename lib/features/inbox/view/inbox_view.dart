import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/inbox/bloc/inbox_cubit.dart';
import 'package:genesis_workspace/features/inbox/view/section_header.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  late final Future _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<InboxCubit>().getLastMessages();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxCubit, InboxState>(
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(title: context.t.inbox.title),
          body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final hasMessages = state.dmMessages.isNotEmpty || state.channelMessages.isNotEmpty;
              if (!hasMessages) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.all_inbox, color: Colors.lightGreen),
                    Center(
                      child: Text(
                        context.t.inbox.noMessages,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (state.dmMessages.isNotEmpty) SectionHeader(title: context.t.inbox.dmTab),
                  ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    itemCount: state.dmMessages.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final user = state.dmMessages.entries.elementAt(index);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(user.key, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: state.pendingId == user.value.first.senderId
                            ? CupertinoActivityIndicator()
                            : Badge.count(count: user.value.length),
                        onTap: state.pendingId != null
                            ? null
                            : () async {
                                final userId = user.value.first.senderId;
                                final UserEntity userEntity = await context
                                    .read<InboxCubit>()
                                    .getUserById(userId);
                                final DmUserEntity dmUser = userEntity.toDmUser();
                                context.pushNamed(Routes.chat, extra: dmUser);
                              },
                      );
                    },
                  ),
                  if (state.channelMessages.isNotEmpty) const SizedBox(height: 16),
                  if (state.channelMessages.isNotEmpty)
                    SectionHeader(title: context.t.inbox.channelsTab),
                  ...state.channelMessages.entries.map(
                    (channelMessage) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(left: 16),
                      initiallyExpanded: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              channelMessage.key,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Badge.count(count: channelMessage.value.length),
                        ],
                      ),
                      children: channelMessage.value.entries.map((entry) {
                        final topicName = entry.key.isEmpty ? context.t.allMessages : entry.key;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(topicName, style: Theme.of(context).textTheme.bodySmall),
                          trailing: state.pendingId == entry.value.first.streamId
                              ? CupertinoActivityIndicator()
                              : Badge.count(count: entry.value.length),
                          onTap: state.pendingId != null
                              ? null
                              : () async {
                                  final streamId = entry.value.first.streamId;
                                  final topicName = entry.value.first.subject;
                                  final maxId = entry.value.last.id;
                                  final channel = await context.read<InboxCubit>().getChannelById(
                                    streamId!,
                                  );
                                  context.pushNamed(
                                    Routes.channelChatTopic,
                                    pathParameters: {
                                      'channelId': channel.streamId.toString(),
                                      'topicName': topicName,
                                    },
                                  );
                                },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
