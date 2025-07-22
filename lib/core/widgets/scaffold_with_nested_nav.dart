import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/home/view/user_avatar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
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

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void initState() {
    _future = Future.wait<void>([
      context.read<RealTimeCubit>().init(),
      context.read<ProfileCubit>().getOwnUser(),
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
                    NavigationRailDestination(label: Text('Home'), icon: Icon(Icons.home)),
                    NavigationRailDestination(
                      label: Text('Profile'),
                      icon: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return UserAvatar(avatarUrl: state.user?.avatarUrl);
                        },
                      ),
                    ),
                    NavigationRailDestination(label: Text('Settings'), icon: Icon(Icons.settings)),
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
                  onTap: _goBranch,
                  items: [
                    BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
                    BottomNavigationBarItem(
                      label: 'Profile',
                      icon: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return UserAvatar(avatarUrl: state.user?.avatarUrl);
                        },
                      ),
                    ),
                    BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings)),
                  ],
                  // onDestinationSelected: _goBranch,
                ),
        );
      },
    );
  }
}
