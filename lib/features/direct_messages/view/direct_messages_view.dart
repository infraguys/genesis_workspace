import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class DirectMessagesView extends StatefulWidget {
  const DirectMessagesView({super.key});

  @override
  State<DirectMessagesView> createState() => _DirectMessagesViewState();
}

class _DirectMessagesViewState extends State<DirectMessagesView> {
  final TextEditingController _searchController = TextEditingController();
  late final Future _future;
  bool _isFutureInitialized = false;

  @override
  void didChangeDependencies() {
    if (!_isFutureInitialized) {
      _future = context.read<DirectMessagesCubit>().getUsers();
      _isFutureInitialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Row(
          children: [
            Expanded(child: Text(context.t.navBar.directMessages)),
            if (currentSize(context) > ScreenSize.tablet)
              SizedBox(width: 250, child: _buildSearchField(context)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ),
      ),
      body: Column(
        children: [
          if (currentSize(context) <= ScreenSize.tablet)
            Padding(padding: const EdgeInsets.all(8.0), child: _buildSearchField(context)),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                if (profileState.user != null) {
                  context.read<DirectMessagesCubit>().setSelfUser(profileState.user);
                }

                return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
                  builder: (context, state) {
                    return FutureBuilder(
                      future: _future,
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Some error..."));
                        }

                        if (state.users.isEmpty) {
                          return Center(child: Text("No users found"));
                        }

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: currentSize(context) >= ScreenSize.desktop ? 24 : 12,
                            vertical: 12,
                          ),
                          itemCount: state.filteredUsers.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final DmUserEntity user = state.filteredUsers[index];

                            return _buildUserTile(context, theme, user, state);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final cubit = context.read<DirectMessagesCubit>();
    return TextField(
      controller: _searchController,
      onChanged: cubit.searchUsers,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: context.t.search,
        filled: true,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    ThemeData theme,
    DmUserEntity user,
    DirectMessagesState state,
  ) {
    Widget? subtitle;

    if (state.typingUsers.contains(user.userId)) {
      subtitle = Text("${context.t.typing}...");
    } else if (user.presenceStatus == PresenceStatus.active) {
      subtitle = Row(
        spacing: 8,
        children: [
          Text(context.t.online, style: theme.textTheme.labelSmall),
          const Icon(Icons.circle, color: Colors.green, size: 10),
        ],
      );
    } else {
      final lastSeen = DateTime.fromMillisecondsSinceEpoch((user.presenceTimestamp * 1000).toInt());
      final timeAgo = timeAgoText(context, lastSeen);

      subtitle = Text(
        isJustNow(lastSeen) ? context.t.wasOnlineJustNow : context.t.wasOnline(time: timeAgo),
        style: theme.textTheme.labelSmall,
      );
    }

    return ListTile(
      onTap: () => context.pushNamed(Routes.chat, extra: user),
      title: Text(user.fullName, overflow: TextOverflow.ellipsis),
      subtitle: subtitle,
      leading: UserAvatar(avatarUrl: user.avatarUrl),
      trailing: Badge.count(
        count: user.unreadMessages.length,
        isLabelVisible: user.unreadMessages.isNotEmpty,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
