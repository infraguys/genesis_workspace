import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/chats/common/widgets/dm_search_field.dart';
import 'package:genesis_workspace/features/chats/common/widgets/user_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class SliverDirectMessagesList extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController searchController;
  final bool showAllUsers;
  final VoidCallback onToggleShowAllUsers;

  const SliverDirectMessagesList({
    super.key,
    required this.theme,
    required this.searchController,
    required this.showAllUsers,
    required this.onToggleShowAllUsers,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: theme.colorScheme.inversePrimary,
          pinned: true,
          title: Row(
            children: [
              Expanded(child: Text(context.t.navBar.directMessages)),
              _ShowAllUsersToggleButton(showAllUsers: showAllUsers, onToggle: onToggleShowAllUsers),
            ],
          ),
        ),
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
                  return UserTile(
                    user: userEntity,
                    onTap: () {
                      if (currentSize(context) > ScreenSize.lTablet) {
                        context.read<DirectMessagesCubit>().selectUserChat(
                          userId: userEntity.userId,
                          unreadMessagesCount: userEntity.unreadMessages.length,
                        );
                      } else {
                        context.pushNamed(
                          Routes.chat,
                          pathParameters: {'userId': userEntity.userId.toString()},
                          extra: {'unreadMessagesCount': userEntity.unreadMessages.length},
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

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
