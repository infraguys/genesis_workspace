import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/direct_messages/view/dm_search_field.dart';
import 'package:genesis_workspace/features/direct_messages/view/user_tile.dart';
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
                    child: _SliverDirectMessagesList(
                      theme: theme,
                      searchController: _searchController,
                      showAllUsers: directMessagesState.showAllUsers,
                      onToggleShowAllUsers: context.read<DirectMessagesCubit>().toggleShowAllUsers,
                    ),
                  );

                  if (!isDesktopLayout) {
                    // Мобильный / планшетный layout: показываем только список
                    return directMessagesListPane;
                  }

                  // Desktop layout: слева список (Slivers), справа — чат
                  return Row(
                    children: [
                      directMessagesListPane,
                      directMessagesState.selectedUserId != null
                          ? Expanded(
                              key: ObjectKey(directMessagesState.selectedUserId),
                              child: Chat(
                                userId: directMessagesState.selectedUserId!,
                                unreadMessagesCount:
                                    directMessagesState.selectedUnreadMessagesCount,
                              ),
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

/// Отдельный виджет с CustomScrollView и всеми Slivers.
/// Внутри:
/// - SliverAppBar (заголовок + переключатель "все пользователи / недавние").
/// - SliverPersistentHeader (строка поиска; исчезает при скролле вниз).
/// - SliverPadding + SliverList (данные: recentDmsUsers или filteredUsers).
class _SliverDirectMessagesList extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController searchController;
  final bool showAllUsers;
  final VoidCallback onToggleShowAllUsers;

  const _SliverDirectMessagesList({
    required this.theme,
    required this.searchController,
    required this.showAllUsers,
    required this.onToggleShowAllUsers,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Поведение: строка поиска будет скрываться при прокрутке вниз (floating + snap).
      slivers: [
        SliverAppBar(
          backgroundColor: theme.colorScheme.inversePrimary,
          pinned: true,
          title: Row(
            children: [
              Expanded(child: Text(context.t.navBar.directMessages)),
              // Переключатель источника: недавние / все
              _ShowAllUsersToggleButton(showAllUsers: showAllUsers, onToggle: onToggleShowAllUsers),
            ],
          ),
        ),

        // Строка поиска, исчезает при скролле вниз (floating + snap)
        SliverPersistentHeader(
          floating: true,
          pinned: false,
          delegate: _SearchBarHeaderDelegate(
            minExtentHeight: 0, // полностью схлопывается
            maxExtentHeight: 56,
            child: Container(
              color: theme.colorScheme.inversePrimary, // чтобы не мигало под AppBar
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DmSearchField(
                searchController: searchController,
                searchUsers: context.read<DirectMessagesCubit>().searchUsers,
              ),
            ),
          ),
        ),

        // Список пользователей
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: currentSize(context) >= ScreenSize.lTablet ? 0 : 12,
            vertical: 12,
          ),
          sliver: BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
            buildWhen: (previous, next) =>
                previous.filteredUsers != next.filteredUsers ||
                previous.filteredRecentDmsUsers != next.filteredRecentDmsUsers ||
                previous.showAllUsers != next.showAllUsers,
            builder: (context, state) {
              final List<DmUserEntity> displayedUsers = state.showAllUsers
                  ? state.filteredUsers
                  : state.filteredRecentDmsUsers;

              if (displayedUsers.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(context.t.noRecentDialogs)),
                  ),
                );
              }

              // Разделители между элементами, аналог ListView.separated
              final int sliverChildCount = displayedUsers.length * 2 - 1;

              return SliverList.builder(
                itemCount: sliverChildCount,
                itemBuilder: (BuildContext context, int sliverIndex) {
                  if (sliverIndex.isOdd) {
                    return const Divider(height: 1);
                  }
                  final int userIndex = sliverIndex ~/ 2;
                  final DmUserEntity userEntity = displayedUsers[userIndex];
                  return UserTile(user: userEntity);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Кнопка-переключатель "Показывать всех / Показывать недавние".
class _ShowAllUsersToggleButton extends StatelessWidget {
  final bool showAllUsers;
  final VoidCallback onToggle;

  const _ShowAllUsersToggleButton({required this.showAllUsers, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final String tooltipText = showAllUsers
        ? 'Показать недавние диалоги'
        : 'Показать всех пользователей';

    return Tooltip(
      message: tooltipText,
      child: IconButton(
        onPressed: onToggle,
        icon: Icon(showAllUsers ? Icons.history : Icons.groups),
      ),
    );
  }
}

/// Делегат для SliverPersistentHeader, который позволяет схлопывать/показывать строку поиска.
class _SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtentHeight;
  final double maxExtentHeight;
  final Widget child;

  _SearchBarHeaderDelegate({
    required this.minExtentHeight,
    required this.maxExtentHeight,
    required this.child,
  });

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => math.max(maxExtentHeight, minExtentHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Простая реализация: просто обрезаем по высоте.
    final double availableHeight = math.max(minExtentHeight, maxExtentHeight - shrinkOffset);

    return SizedBox(
      height: availableHeight,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: availableHeight, // чтобы не дёргалось при схлопывании
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarHeaderDelegate oldDelegate) {
    return minExtentHeight != oldDelegate.minExtentHeight ||
        maxExtentHeight != oldDelegate.maxExtentHeight ||
        child != oldDelegate.child;
  }
}
