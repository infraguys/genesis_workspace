import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/features/chats/common/widgets/sliver_direct_messages_list.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class DirectMessagesView extends StatefulWidget {
  final int? initialUserId;
  const DirectMessagesView({super.key, this.initialUserId});

  @override
  State<DirectMessagesView> createState() => _DirectMessagesViewState();
}

class _DirectMessagesViewState extends State<DirectMessagesView> {
  final TextEditingController _searchController = TextEditingController();
  late final Future _initialLoadFuture;
  bool _isInitialLoadScheduled = false;

  static const double desktopListPaneWidth = 400;

  @override
  void initState() {
    super.initState();
    context.read<DirectMessagesCubit>().selectUserChat(userId: widget.initialUserId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialLoadScheduled) {
      _initialLoadFuture = context.read<DirectMessagesCubit>().getUsers();
      _isInitialLoadScheduled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<DirectMessagesCubit, DirectMessagesState>(
      listenWhen: (previous, next) => previous.selectedUserId != next.selectedUserId,
      listener: (context, state) {
        if (currentSize(context) > ScreenSize.lTablet) {
          final String targetPath = (state.selectedUserId == null)
              ? Routes.directMessages
              : '${Routes.directMessages}/${state.selectedUserId}';

          final String currentLocation = GoRouterState.of(context).uri.toString();

          if (currentLocation != targetPath) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              updateBrowserUrlPath(targetPath);
            });
          }
        }
      },
      builder: (context, directMessagesState) {
        return Scaffold(
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              if (profileState.user != null) {
                context.read<DirectMessagesCubit>().setSelfUser(profileState.user);
              }

              return FutureBuilder(
                future: _initialLoadFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Some error...'));
                  }

                  if (directMessagesState.users.isEmpty) {
                    return Center(child: Text('No users found'));
                  }

                  final bool isDesktopLayout = currentSize(context) > ScreenSize.lTablet;

                  final Widget directMessagesListPane = Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktopLayout
                          ? desktopListPaneWidth
                          : (MediaQuery.sizeOf(context).width - (currentSize(context) > ScreenSize.tablet ? 114 : 0)),
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
                    child: SliverDirectMessagesList(
                      theme: theme,
                      searchController: _searchController,
                      showAllUsers: directMessagesState.showAllUsers,
                      onToggleShowAllUsers: context.read<DirectMessagesCubit>().toggleShowAllUsers,
                    ),
                  );

                  if (!isDesktopLayout) {
                    return directMessagesListPane;
                  }
                  return Row(
                    children: [
                      directMessagesListPane,
                      directMessagesState.selectedUserId != null
                          ? Expanded(
                              key: ObjectKey(directMessagesState.selectedUserId),
                              child: SizedBox(),
                              // child: Chat(
                              //   userIds: [directMessagesState.selectedUserId!],
                              //   unreadMessagesCount:
                              //       directMessagesState.selectedUnreadMessagesCount,
                              // ),
                            )
                          : Expanded(child: Center(child: Text(context.t.selectAnyChat))),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
