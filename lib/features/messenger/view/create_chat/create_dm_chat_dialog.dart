import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CreateDmChatDialog extends StatefulWidget {
  const CreateDmChatDialog({super.key});

  @override
  State<CreateDmChatDialog> createState() => _CreateDmChatDialogState();
}

class _CreateDmChatDialogState extends State<CreateDmChatDialog> with OpenChatMixin {
  final TextEditingController _searchController = TextEditingController();
  late final DirectMessagesCubit directMessageCubit;

  @override
  void initState() {
    super.initState();
    directMessageCubit = context.read<DirectMessagesCubit>();
    directMessageCubit.searchUsers('');
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    directMessageCubit.searchUsers(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    directMessageCubit.searchUsers('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 560,
        child: Column(
          children: [
            Padding(
              padding: const .fromLTRB(16, 16, 8, 8),
              child: Text(
                context.t.directMessage.createDialog.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const .fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.t.directMessage.createDialog.searchHint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
                builder: (context, state) {
                  final int? selfId = state.selfUser?.userId;
                  final List<DmUserEntity> users = state.filteredUsers
                      .where((u) => u.isActive && u.userId != selfId)
                      .toList();
                  if (state.isUsersPending) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (users.isEmpty && !state.isUsersPending) {
                    return Center(child: Text(context.t.directMessage.createDialog.noUsers));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return InkWell(
                        onTap: () {
                          final selfUserId = context.read<ProfileCubit>().state.user?.userId ?? -1;
                          openChat(
                            context,
                            chatId: -1,
                            membersIds: {user.userId, selfUserId},
                          );
                          context.pop();
                        },
                        child: Padding(
                          padding: const .symmetric(horizontal: 8, vertical: 6),
                          child: Row(
                            children: [
                              UserAvatar(avatarUrl: user.avatarUrl, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      overflow: .ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      user.email,
                                      overflow: .ellipsis,
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const .all(12),
              child: Row(
                mainAxisAlignment: .end,
                spacing: 8.0,
                children: [
                  TextButton(
                    onPressed: context.pop,
                    child: Text(context.t.directMessage.createDialog.cancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
