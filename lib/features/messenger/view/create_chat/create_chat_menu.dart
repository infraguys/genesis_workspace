import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/create_chat/create_chat_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/create_chat/create_channel_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/create_chat/create_dm_chat_dialog.dart';
import 'package:genesis_workspace/features/messenger/view/create_chat/create_group_chat_dialog.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CreateChatMenu extends StatelessWidget with OpenChatMixin {
  final int selfUserId;
  final VoidCallback? onClose;
  const CreateChatMenu({
    super.key,
    required this.selfUserId,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        InkWell(
          onTap: () async {
            onClose?.call();
            final channelId = await showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<DirectMessagesCubit>()..getUsers()),
                  ],
                  child: CreateDmChatDialog(),
                );
              },
            );
            if (channelId != null) {
              openChannel(context, channelId: channelId);
            }
          },
          child: Row(
            spacing: 16,
            children: [
              Assets.icons.personAdd.svg(),
              Text(context.t.messengerView.createChatMenu.startChat),
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            onClose?.call();
            final channelId = await showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<DirectMessagesCubit>()..getUsers()),
                    BlocProvider(create: (_) => getIt<CreateChatCubit>()),
                  ],

                  child: CreateChannelDialog(),
                );
              },
            );
            if (channelId != null) {
              openChannel(context, channelId: channelId);
            }
          },
          child: Row(
            spacing: 16,
            children: [
              Assets.icons.campaign.svg(),
              Text(context.t.messengerView.createChatMenu.createChannel),
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            onClose?.call();
            await showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return BlocProvider(
                  create: (_) => getIt<DirectMessagesCubit>()..getUsers(),
                  child: CreateGroupChatDialog(
                    onCreate: (membersIds) {
                      context.pop();
                      openChat(
                        context,
                        chatId: -1,
                        membersIds: {...membersIds, selfUserId},
                      );
                    },
                  ),
                );
              },
            );
          },
          child: Row(
            spacing: 16,
            children: [
              Assets.icons.group.svg(),
              Text(context.t.messengerView.createChatMenu.createGroupChat),
            ],
          ),
        ),
      ],
    );
  }
}
