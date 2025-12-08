import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CreateGroupChatDialog extends StatefulWidget {
  final void Function(Set<int> membersIds) onCreate;

  const CreateGroupChatDialog({super.key, required this.onCreate});

  @override
  State<CreateGroupChatDialog> createState() => _CreateGroupChatDialogState();
}

class _CreateGroupChatDialogState extends State<CreateGroupChatDialog> {
  final TextEditingController _searchController = TextEditingController();
  late final DirectMessagesCubit directMessageCubit;
  final Set<int> _selectedIds = <int>{};

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
                context.t.groupChat.createDialog.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const .fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.t.groupChat.createDialog.searchHint,
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
                  // Move selected users to the top while preserving relative order
                  final List<DmUserEntity> displayUsers = [
                    ...users.where((u) => _selectedIds.contains(u.userId)),
                    ...users.where((u) => !_selectedIds.contains(u.userId)),
                  ];
                  if (users.isEmpty) {
                    return Center(child: Text(context.t.groupChat.createDialog.noUsers));
                  }
                  return ListView.builder(
                    itemCount: displayUsers.length,
                    itemBuilder: (context, index) {
                      final user = displayUsers[index];
                      final bool selected = _selectedIds.contains(user.userId);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedIds.remove(user.userId);
                            } else {
                              _selectedIds.add(user.userId);
                            }
                          });
                        },
                        child: Padding(
                          padding: const .symmetric(horizontal: 8, vertical: 6),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedIds.add(user.userId);
                                    } else {
                                      _selectedIds.remove(user.userId);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 4),
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
                    child: Text(context.t.groupChat.createDialog.cancel),
                  ),
                  FilledButton(
                    onPressed: _selectedIds.isNotEmpty ? () => widget.onCreate(_selectedIds) : null,
                    child: Text(context.t.groupChat.createDialog.create),
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
