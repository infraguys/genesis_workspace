import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_idle_detector/in_app_idle_detector.dart';

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

  void _initIdleDetector() {
    InAppIdleDetector.initialize(
      timeout: Duration(seconds: 5),
      onIdle: () async {
        final UpdatePresenceRequestEntity body = UpdatePresenceRequestEntity(
          lastUpdateId: -1,
          status: PresenceStatus.idle,
          newUserInput: true,
          pingOnly: false,
        );
        await context.read<ProfileCubit>().updatePresence(body);
      },
      onActive: () async {
        final UpdatePresenceRequestEntity body = UpdatePresenceRequestEntity(
          lastUpdateId: -1,
          status: PresenceStatus.active,
          newUserInput: true,
          pingOnly: false,
        );
        await context.read<ProfileCubit>().updatePresence(body);
      },
    );
  }

  void _pauseIdleDetector() {
    InAppIdleDetector.pause();
  }

  @override
  void initState() {
    _initIdleDetector();
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
    _pauseIdleDetector();
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
                BlocBuilder<MessagesCubit, MessagesState>(
                  builder: (context, state) {
                    return NavigationRail(
                      selectedIndex: widget.navigationShell.currentIndex,
                      onDestinationSelected: _goBranch,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        NavigationRailDestination(
                          label: Text(context.t.navBar.directMessages),
                          icon: Badge(
                            isLabelVisible: state.messages.any(
                              (message) => message.type == MessageType.private,
                            ),
                            child: Icon(Icons.people),
                          ),
                        ),
                        NavigationRailDestination(
                          label: Text(context.t.navBar.channels),
                          icon: Badge(
                            isLabelVisible: state.messages.any(
                              (message) => message.type == MessageType.stream,
                            ),
                            child: Icon(Icons.chat),
                          ),
                        ),
                        NavigationRailDestination(
                          label: Text(context.t.navBar.menu),
                          icon: Icon(Icons.menu),
                        ),
                        NavigationRailDestination(
                          label: Text(context.t.navBar.settings),
                          icon: Icon(Icons.settings),
                        ),
                      ],
                    );
                  },
                ),
                const VerticalDivider(thickness: 1, width: 1),
              ],
              Expanded(child: widget.navigationShell),
            ],
          ),
          bottomNavigationBar: currentSize(context) > ScreenSize.tablet
              ? null
              : BlocBuilder<MessagesCubit, MessagesState>(
                  builder: (context, state) {
                    return BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        return BottomNavigationBar(
                          currentIndex: widget.navigationShell.currentIndex,
                          type: BottomNavigationBarType.shifting,
                          onTap: _goBranch,
                          items: [
                            BottomNavigationBarItem(
                              label: context.t.navBar.directMessages,
                              icon: Badge(
                                isLabelVisible: state.messages.any(
                                  (message) =>
                                      (message.type == MessageType.private &&
                                      message.senderId != profileState.user?.userId),
                                ),
                                child: Icon(Icons.people),
                              ),
                            ),
                            BottomNavigationBarItem(
                              label: context.t.navBar.channels,
                              icon: Badge(
                                isLabelVisible: state.messages.any(
                                  (message) =>
                                      (message.type == MessageType.stream &&
                                      message.senderId != profileState.user?.userId),
                                ),
                                child: Icon(Icons.chat),
                              ),
                            ),
                            BottomNavigationBarItem(
                              label: context.t.navBar.menu,
                              icon: Icon(Icons.menu),
                            ),
                            BottomNavigationBarItem(
                              label: context.t.navBar.settings,
                              icon: Icon(Icons.settings),
                            ),
                          ],
                          // onDestinationSelected: _goBranch,
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
