import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/palettes/palette.dart';
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
    final theme = Theme.of(context);
    final iconColors = theme.extension<IconColors>()!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          _CreateChatItem(
            onCreate: () async {
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
            icon: Assets.icons.personAdd.svg(
              colorFilter: ColorFilter.mode(
                iconColors.base,
                BlendMode.srcIn,
              ),
            ),
            label: context.t.messengerView.createChatMenu.startChat,
          ),
          _CreateChatItem(
            onCreate: () async {
              onClose?.call();
              await showDialog(
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
            },
            icon: Assets.icons.campaign.svg(
              colorFilter: ColorFilter.mode(
                iconColors.base,
                BlendMode.srcIn,
              ),
            ),
            label: context.t.messengerView.createChatMenu.createChannel,
          ),
          _CreateChatItem(
            onCreate: () async {
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
            icon: Assets.icons.group.svg(
              width: 25,
              colorFilter: ColorFilter.mode(
                iconColors.base,
                BlendMode.srcIn,
              ),
            ),
            label: context.t.messengerView.createChatMenu.createGroupChat,
          ),
        ],
      ),
    );
  }
}

class _CreateChatItem extends StatelessWidget {
  final VoidCallback onCreate;
  final Widget icon;
  final String label;

  const _CreateChatItem({super.key, required this.onCreate, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: InkWell(
        onTap: onCreate,
        child: Container(
          padding: .symmetric(vertical: 4, horizontal: 12),
          height: 40,
          child: Row(
            spacing: 16,
            children: [
              icon,
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
