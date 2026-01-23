import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/draft_type.dart';
import 'package:genesis_workspace/core/mixins/chat/open_dm_chat_mixin.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class DraftsView extends StatelessWidget with OpenDmChatMixin {
  const DraftsView({super.key});

  Future<void> _showEditDraftDialog(BuildContext context, DraftEntity draft) async {
    if (draft.id == null) {
      return;
    }

    final controller = TextEditingController(text: draft.content);
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    String? updatedContent;

    try {
      updatedContent = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              context.t.contextMenu.edit,
              style: theme.textTheme.titleMedium,
            ),
            content: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColors.text100,
              ),
              decoration: InputDecoration(
                hintText: context.t.input.placeholder,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => dialogContext.pop(),
                child: Text(context.t.general.close),
              ),
              ElevatedButton(
                onPressed: () => dialogContext.pop(controller.text),
                child: Text(context.t.contextMenu.edit),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }

    if (updatedContent == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await context.read<DraftsCubit>().editDraft(draft.id!, updatedContent);
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                color: Color(0xffB86BEF),
              ),
              child: Assets.icons.pencilFilled.svg(
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 12),
            Text(
              context.t.drafts.title,
            ),
          ],
        ),
      ),
      body: BlocBuilder<DraftsCubit, DraftsState>(
        builder: (context, state) {
          if (state.drafts.isEmpty) {
            return Center(
              child: Text(
                context.t.drafts.noDrafts,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
          final bool isCompact = currentSize(context) <= ScreenSize.tablet;
          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 24,
              vertical: 16,
            ),
            itemCount: state.drafts.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final draft = state.drafts[index];
              return _DraftCard(
                draft: draft,
                isCompact: isCompact,
                isPending: state.pendingDraftId == draft.id,
                onDelete: () async {
                  if (draft.id != null) {
                    await context.read<DraftsCubit>().deleteDraft(draft.id!);
                  }
                },
                onGoToChat: () {
                  final chats = context.read<MessengerCubit>().state.chats;
                  if (draft.type == .private) {
                    final draftTo = draft.to;
                    final myUserId = context.read<ProfileCubit>().state.user?.userId ?? -1;
                    final List<int> updatedDraftTo = [...draftTo, myUserId];
                    final updatedDraft = draft.copyWith(to: updatedDraftTo);
                    final chat = chats.firstWhereOrNull((chat) => updatedDraft.matchesUsers(chat.dmIds ?? []));
                    if (chat != null) {
                      openChat(context, membersIds: chat.dmIds!.toSet(), chatId: chat.id);
                    }
                  } else {
                    final chat = chats.firstWhereOrNull((chat) => chat.streamId == draft.to.first);
                    if (chat != null) {
                      openChannel(context, channelId: chat.streamId!, topicName: draft.topic);
                    }
                  }
                },
                onEdit: () => _showEditDraftDialog(context, draft),
              );
            },
          );
        },
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.isCompact,
    required this.isPending,
    required this.onDelete,
    required this.onGoToChat,
    required this.onEdit,
  });

  final DraftEntity draft;
  final bool isCompact;
  final bool isPending;
  final VoidCallback onDelete;
  final VoidCallback onGoToChat;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final cardColors = theme.extension<CardColors>()!;
    final String recipients = draft.to.isEmpty ? '-' : draft.to.join(', ');
    final String? topic = draft.topic.trim().isEmpty ? null : draft.topic.trim();
    final String typeLabel = draft.type == DraftType.stream ? context.t.inbox.channelsTab : context.t.inbox.dmTab;

    return Container(
      padding: .all(16),
      decoration: BoxDecoration(
        color: cardColors.onBackgroundCard,
        borderRadius: .circular(12),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .start,
                  children: [
                    Text(
                      draft.content,
                      maxLines: isCompact ? 4 : 6,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColors.text100,
                      ),
                    ),
                    SizedBox(height: 8),
                    DefaultTextStyle(
                      style:
                          theme.textTheme.labelSmall?.copyWith(
                            color: textColors.text50,
                          ) ??
                          TextStyle(color: textColors.text50),
                      child: IconTheme(
                        data: IconThemeData(
                          size: 16,
                          color: textColors.text50,
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _DraftMetaItem(
                              icon: draft.type == DraftType.stream ? Icons.forum_outlined : Icons.alternate_email,
                              label: typeLabel,
                            ),
                            _DraftMetaItem(
                              icon: Icons.group_outlined,
                              label: recipients,
                            ),
                            if (topic != null)
                              _DraftMetaItem(
                                icon: Icons.tag_outlined,
                                label: topic,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
                children: [
                  IconButton(
                    onPressed: onGoToChat,
                    icon: const Icon(Icons.chat_bubble_outline),
                    tooltip: context.t.open,
                  ),
                  IconButton(
                    onPressed: isPending ? null : onEdit,
                    icon: Assets.icons.pencilFilled.svg(
                      colorFilter: ColorFilter.mode(
                        isPending ? theme.disabledColor : Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    tooltip: context.t.contextMenu.edit,
                  ),
                  IconButton(
                    onPressed: isPending ? null : onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    tooltip: context.t.contextMenu.delete,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DraftMetaItem extends StatelessWidget {
  const _DraftMetaItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
