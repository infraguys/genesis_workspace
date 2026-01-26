import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/create_chat/create_chat_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CreateChannelDialog extends StatefulWidget {
  const CreateChannelDialog({super.key});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> with OpenChatMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final DirectMessagesCubit directMessageCubit;
  final Set<int> _selectedIds = <int>{};
  bool _announce = false;
  bool _inviteOnly = false;
  late final int _maxNameLength;
  late final int _maxDescriptionLength;
  String? _nameError;
  String? _descriptionError;
  String? _creationError;

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

  String? _validateName(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return context.t.channel.createDialog.nameRequired;
    }
    if (trimmed.length > _maxNameLength) {
      return context.t.channel.createDialog.nameMaxLength(max: _maxNameLength);
    }
    return null;
  }

  String? _validateDescription(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length > _maxDescriptionLength) {
      return context.t.channel.createDialog.descriptionMaxLength(max: _maxDescriptionLength);
    }
    return null;
  }

  void _onNameChanged(String value) {
    setState(() {
      _nameError = _validateName(value);
    });
  }

  void _onDescriptionChanged(String value) {
    setState(() {
      _descriptionError = _validateDescription(value);
    });
  }

  bool get _canSubmit {
    return _validateName(_nameController.text) == null && _validateDescription(_descriptionController.text) == null;
  }

  void _submit() async {
    try {
      final String? nameError = _validateName(_nameController.text);
      final String? descriptionError = _validateDescription(_descriptionController.text);
      setState(() {
        _nameError = nameError;
        _descriptionError = descriptionError;
      });
      if (nameError != null || descriptionError != null) return;

      final myUserId = context.read<ProfileCubit>().state.user?.userId ?? -1;
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final channelId = await context.read<CreateChatCubit>().createChannel(
        name: name,
        description: description.isEmpty ? null : description,
        announce: _announce,
        inviteOnly: _inviteOnly,
        selectedUsers: [..._selectedIds.toList(), myUserId],
      );
      await context.read<MessengerCubit>().addChannelById(channelId);
      context.pop();
      openChannel(context, channelId: channelId);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data['code'];
      final msg = data['msg'];
      switch (code) {
        case 'CHANNEL_ALREADY_EXISTS':
          setState(() {
            _nameError = context.t.channel.createDialog.nameAlreadyExists;
          });
        default:
          setState(() {
            _creationError = msg;
          });
      }
    }
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
    final t = context.t;
    return Dialog(
      constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
      child: BlocBuilder<CreateChatCubit, CreateChatState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: .min,
            children: [
              Padding(
                padding: const .fromLTRB(16, 16, 8, 8),
                child: Text(
                  t.channel.createDialog.title,
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
                      t.channel.createDialog.nameLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: textColors.text30,
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      onChanged: _onNameChanged,
                      decoration: InputDecoration(
                        hintText: t.channel.createDialog.nameHint,
                        isDense: true,
                        border: const OutlineInputBorder(),
                        errorText: _nameError,
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
                      t.channel.createDialog.descriptionLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: textColors.text30,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                      onChanged: _onDescriptionChanged,
                      decoration: InputDecoration(
                        hintText: t.channel.createDialog.descriptionHint,
                        isDense: true,
                        border: const OutlineInputBorder(),
                        errorText: _descriptionError,
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
                        t.channel.createDialog.announce,
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
                        t.channel.createDialog.inviteOnly,
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
                    hintText: t.groupChat.createDialog.searchHint,
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
                      return Center(child: Text(t.groupChat.createDialog.noUsers));
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
              if (_creationError != null)
                Text(
                  _creationError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              Padding(
                padding: const .all(12),
                child: Row(
                  mainAxisAlignment: .end,
                  spacing: 8.0,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(t.groupChat.createDialog.cancel),
                    ),
                    FilledButton(
                      onPressed: _canSubmit ? _submit : null,
                      child: Text(t.groupChat.createDialog.create),
                    ).pending(state is CreateChatPending),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
