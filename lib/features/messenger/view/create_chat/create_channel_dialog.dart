import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/create_chat/create_chat_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CreateChannelDialog extends StatefulWidget {
  const CreateChannelDialog({super.key});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final DirectMessagesCubit directMessageCubit;
  final Set<int> _selectedIds = <int>{};
  bool _announce = false;
  bool _inviteOnly = false;
  late final int _maxNameLength;
  late final int _maxDescriptionLength;

  @override
  void initState() {
    super.initState();
    directMessageCubit = context.read<DirectMessagesCubit>();
    directMessageCubit.searchUsers('');
    _searchController.addListener(_onSearchChanged);
    final organizationsState = context.read<OrganizationsCubit>().state;
    final org = organizationsState.organizations.firstWhere(
      (org) => org.id == organizationsState.selectedOrganizationId,
    );
    _maxNameLength = org.streamNameMaxLength!;
    _maxDescriptionLength = org.streamDescriptionMaxLength!;
  }

  void _onSearchChanged() {
    directMessageCubit.searchUsers(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    directMessageCubit.searchUsers('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Dialog(
      constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const .fromLTRB(16, 16, 8, 8),
            child: Text(
              "Новый канал",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const .fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Text(
                  "Название канала",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColors.text30,
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Канал для обсуждений",
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const .fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Text(
                  "Описание канала",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColors.text30,
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: "О чем этот канал",
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          Padding(
            padding: const .fromLTRB(12, 4, 12, 4),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _announce,
                  onChanged: (value) {
                    setState(() {
                      _announce = value ?? false;
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    "Оповестить о создании канала",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                CheckboxListTile(
                  value: _inviteOnly,
                  onChanged: (value) {
                    setState(() {
                      _inviteOnly = value ?? false;
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    "Только по приглашению",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
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
                if (state.isUsersPending) {
                  return Center(child: CircularProgressIndicator());
                }
                if (users.isEmpty && !state.isUsersPending) {
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
                  onPressed: () {
                    final myUserId = context.read<ProfileCubit>().state.user?.userId ?? -1;
                    final description = _descriptionController.text.trim();
                    context.read<CreateChatCubit>().createChannel(
                      name: _nameController.text,
                      description: description.isEmpty ? null : description,
                      announce: _announce,
                      inviteOnly: _inviteOnly,
                      selectedUsers: [..._selectedIds.toList(), myUserId],
                    );
                  },
                  child: Text(context.t.groupChat.createDialog.create),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
