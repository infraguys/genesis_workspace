import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/common/entities/exception_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class AddSubscriberToChannelDialog extends StatefulWidget {
  const AddSubscriberToChannelDialog({
    super.key,
    required this.streamName,
    required this.users,
    required this.channelUsers,
    required this.channelMembersInfoCubit,
  });

  final String streamName;
  final List<DmUserEntity> users;
  final List<DmUserEntity> channelUsers;
  final ChannelMembersInfoCubit channelMembersInfoCubit;

  @override
  State<AddSubscriberToChannelDialog> createState() => _AddSubscriberToChannelDialogState();
}

class _AddSubscriberToChannelDialogState extends State<AddSubscriberToChannelDialog> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedIds = {};
  String _searchQuery = '';
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<DmUserEntity> get _availableUsers {
    final channelUserIds = widget.channelUsers.map((user) => user.userId).toSet();
    final filtered = widget.users.where((user) {
      if (channelUserIds.contains(user.userId)) {
        return false;
      }
      if (_searchQuery.isEmpty) {
        return true;
      }
      return user.fullName.toLowerCase().contains(_searchQuery) || user.email.toLowerCase().contains(_searchQuery);
    }).toList();

    return [
      ...filtered.where((user) => _selectedIds.contains(user.userId)),
      ...filtered.where((user) => !_selectedIds.contains(user.userId)),
    ];
  }

  Future<void> _submit() async {
    try {
      if (_selectedIds.isEmpty || _isSubmitting) {
        return;
      }
      setState(() {
        _isSubmitting = true;
      });

      await widget.channelMembersInfoCubit.addSubscribersToChannel(
        streamName: widget.streamName,
        userIds: _selectedIds.toList(growable: false),
      );

      if (!mounted) {
        return;
      }

      context.pop();

      setState(() {
        _isSubmitting = false;
      });
    } on ServerExceptionEntity catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.msg;
      });
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final t = context.t;
    final users = _availableUsers;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.channel.addSubscribersDialog.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColors.text100,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: t.channel.addSubscribersDialog.searchHint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Assets.icons.search.svg(
                        width: 28,
                        height: 28,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: users.isEmpty
                      ? Center(
                          child: Text(
                            t.channel.addSubscribersDialog.noUsersFound,
                            style: theme.textTheme.bodyMedium?.copyWith(color: textColors.text30),
                          ),
                        )
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final selected = _selectedIds.contains(user.userId);
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.fullName,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          Text(
                                            user.email,
                                            overflow: TextOverflow.ellipsis,
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
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _selectedIds.isNotEmpty && !_isSubmitting ? _submit : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            t.channel.addSubscribersDialog.add(count: _selectedIds.length),
                          ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text(t.general.cancel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
