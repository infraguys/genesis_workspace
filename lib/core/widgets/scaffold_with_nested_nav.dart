import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/messages/messages_service.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() => _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState extends State<ScaffoldWithNestedNavigation> {
  late final Future _future;
  late final RealTimeCubit _realTimeCubit;

  final messagesService = getIt<MessagesService>();

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void initState() {
    _future = Future.wait([
      context.read<RealTimeCubit>().init(),
      context.read<ProfileCubit>().getOwnUser(),
      context.read<MessagesCubit>().getLastMessages(),
    ]);
    _realTimeCubit = context.read<RealTimeCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _realTimeCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, asyncSnapshot) {
        return Scaffold(
          body: Row(
            children: [
              if (currentSize(context) > ScreenSize.tablet) ...[
                NavigationRail(
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      label: Text(context.t.navBar.directMessages),
                      icon: Icon(Icons.people),
                    ),
                    NavigationRailDestination(
                      label: Text(context.t.navBar.channels),
                      icon: Icon(Icons.chat),
                    ),
                    NavigationRailDestination(
                      label: Text(context.t.navBar.profile),
                      icon: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return UserAvatar(avatarUrl: state.user?.avatarUrl);
                        },
                      ),
                    ),
                    NavigationRailDestination(
                      label: Text(context.t.navBar.settings),
                      icon: Icon(Icons.settings),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
              ],
              Expanded(child: widget.navigationShell),
            ],
          ),
          bottomNavigationBar: currentSize(context) > ScreenSize.tablet
              ? null
              : BottomNavigationBar(
                  currentIndex: widget.navigationShell.currentIndex,
                  type: BottomNavigationBarType.shifting,
                  onTap: _goBranch,
                  items: [
                    BottomNavigationBarItem(
                      label: context.t.navBar.directMessages,
                      icon: Icon(Icons.people),
                    ),
                    BottomNavigationBarItem(
                      label: context.t.navBar.channels,
                      icon: Icon(Icons.chat),
                    ),
                    BottomNavigationBarItem(
                      label: context.t.navBar.profile,
                      icon: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return UserAvatar(avatarUrl: state.user?.avatarUrl);
                        },
                      ),
                    ),
                    BottomNavigationBarItem(
                      label: context.t.navBar.settings,
                      icon: Icon(Icons.settings),
                    ),
                  ],
                  // onDestinationSelected: _goBranch,
                ),
        );
      },
    );
  }
}
