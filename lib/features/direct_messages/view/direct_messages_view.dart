import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/direct_messages/view/dm_search_field.dart';
import 'package:genesis_workspace/features/direct_messages/view/user_tile.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class DirectMessagesView extends StatefulWidget {
  const DirectMessagesView({super.key});

  @override
  State<DirectMessagesView> createState() => _DirectMessagesViewState();
}

class _DirectMessagesViewState extends State<DirectMessagesView> {
  final TextEditingController _searchController = TextEditingController();
  late final Future _future;
  bool _isFutureInitialized = false;

  static const double desktopDmsWidth = 400;

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
              SizedBox(
                width: 250,
                child: DmSearchField(
                  searchController: _searchController,
                  searchUsers: context.read<DirectMessagesCubit>().searchUsers,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (currentSize(context) <= ScreenSize.tablet)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DmSearchField(
                searchController: _searchController,
                searchUsers: context.read<DirectMessagesCubit>().searchUsers,
              ),
            ),
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

                        return Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: currentSize(context) > ScreenSize.lTablet
                                    ? desktopDmsWidth
                                    : (MediaQuery.sizeOf(context).width -
                                          (currentSize(context) > ScreenSize.tablet ? 114 : 0)),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(
                                  horizontal: currentSize(context) >= ScreenSize.lTablet ? 0 : 12,
                                  vertical: 12,
                                ),
                                itemCount: state.filteredUsers.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final DmUserEntity user = state.filteredUsers[index];

                                  return UserTile(user: user);
                                },
                              ),
                            ),
                            (currentSize(context) > ScreenSize.lTablet &&
                                    state.selectedUser != null)
                                ? Expanded(
                                    key: UniqueKey(),
                                    child: Chat(user: state.selectedUser),
                                  )
                                : Expanded(child: Center(child: Text(context.t.selectAnyChannel))),
                          ],
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
}
