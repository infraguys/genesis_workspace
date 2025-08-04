import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
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
                return Center(
                  child: Text(
                    context.t.inbox.noMessages,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final groupedChannels = _groupByChannelAndTopic(state.channelMessages);

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (state.dmMessages.isNotEmpty) SectionHeader(title: context.t.inbox.dmTab),
                  ListView.builder(
                    itemCount: state.dmMessages.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final user = state.dmMessages.entries.elementAt(index);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(user.key, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: _buildUnreadBadge(user.value.length, context),
                        onTap: () async {
                          final UserEntity userEntity = await context
                              .read<InboxCubit>()
                              .getUserById(user.value.first.senderId);
                          final DmUserEntity dmUser = userEntity.toDmUser();
                          context.pushNamed(Routes.chat, extra: dmUser);
                        },
                      );
                    },
                  ),
                  if (groupedChannels.isNotEmpty) const SizedBox(height: 16),
                  if (groupedChannels.isNotEmpty) SectionHeader(title: context.t.inbox.channelsTab),
                  ...groupedChannels.entries.map(
                    (entry) => _buildChannelTile(entry.key, entry.value, context),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Канал с раскрывающимися топиками
  Widget _buildChannelTile(
    String channelName,
    Map<String, List<MessageEntity>> topics,
    BuildContext context,
  ) {
    final totalCount = topics.values.fold<int>(0, (sum, list) => sum + list.length);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(channelName, style: Theme.of(context).textTheme.bodyMedium)),
          _buildUnreadBadge(totalCount, context),
        ],
      ),
      children: topics.entries.map((entry) {
        final topicName = entry.key.isEmpty ? context.t.allMessages : entry.key;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(topicName, style: Theme.of(context).textTheme.bodySmall),
          trailing: _buildUnreadBadge(entry.value.length, context),
          onTap: () {
            // TODO: переход в конкретный топик
          },
        );
      }).toList(),
    );
  }

  /// Бейдж количества сообщений
  Widget _buildUnreadBadge(int count, BuildContext context) {
    return Badge.count(count: count);
  }

  /// Группировка личных сообщений по отправителю
  Map<String, List<MessageEntity>> _groupBySender(List<MessageEntity> messages) {
    final Map<String, List<MessageEntity>> grouped = {};
    for (var msg in messages) {
      grouped.putIfAbsent(msg.senderFullName, () => []).add(msg);
    }
    return grouped;
  }

  /// Группировка каналов: Channel -> {Topic -> [Messages]}
  Map<String, Map<String, List<MessageEntity>>> _groupByChannelAndTopic(
    List<MessageEntity> messages,
  ) {
    final Map<String, Map<String, List<MessageEntity>>> grouped = {};
    for (var msg in messages) {
      final channel = msg.displayRecipient ?? 'Unknown';
      final topic = msg.subject.isEmpty ? '' : msg.subject;
      grouped.putIfAbsent(channel, () => {});
      grouped[channel]!.putIfAbsent(topic, () => []).add(msg);
    }
    return grouped;
  }
}
