import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/app_shell_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_idle_detector/in_app_idle_detector.dart';

class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() => _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState extends State<ScaffoldWithNestedNavigation>
    with WidgetsBindingObserver {
  late final Future _future;
  late final AppShellController appShellController;

  void _goBranch(int index) {
    appShellController.goToBranch(index);
  }

  Future<void> setIdleStatus() async {
    final UpdatePresenceRequestEntity body = UpdatePresenceRequestEntity(
      status: PresenceStatus.idle,
      newUserInput: false,
      pingOnly: false,
    );
    await context.read<ProfileCubit>().updatePresence(body);
  }

  Future<void> setActiveStatus() async {
    final UpdatePresenceRequestEntity body = UpdatePresenceRequestEntity(
      lastUpdateId: -1,
      status: PresenceStatus.active,
      newUserInput: true,
      pingOnly: false,
    );
    await context.read<ProfileCubit>().updatePresence(body);
  }

  void _initIdleDetector() {
    InAppIdleDetector.initialize(
      timeout: Duration(minutes: 2),
      onIdle: () async {
        await setIdleStatus();
      },
      onActive: () async {
        await setActiveStatus();
      },
    );
  }

  void _pauseIdleDetector() {
    InAppIdleDetector.pause();
  }

  @override
  void initState() {
    appShellController = getIt<AppShellController>();
    appShellController.attach(widget.navigationShell);
    _initIdleDetector();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) BrowserContextMenu.disableContextMenu();
    _future = Future.wait([
      context.read<RealTimeCubit>().init(),
      context.read<ProfileCubit>().getOwnUser(),
      context.read<MessagesCubit>().getLastMessages(),
    ]);
    super.initState();
  }

  @override
  void dispose() {
    appShellController.detach();
    _pauseIdleDetector();
    WidgetsBinding.instance.removeObserver(this);
    if (kIsWeb) BrowserContextMenu.enableContextMenu();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        await setIdleStatus();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // if (state.isAuthorized) {
        //   context.goNamed(Routes.directMessages);
        // } else {
        //   context.goNamed(Routes.auth);
        // }
      },
      child: FutureBuilder(
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
                            label: Text(context.t.navBar.allChats),
                            icon: Icon(Icons.chat),
                          ),
                          NavigationRailDestination(
                            label: Text(context.t.navBar.directMessages),
                            icon: Badge(
                              isLabelVisible: state.messages.any(
                                (message) =>
                                    (message.type == MessageType.private &&
                                    message.hasUnreadMessages),
                              ),
                              child: Icon(Icons.people),
                            ),
                          ),
                          NavigationRailDestination(
                            label: Text(context.t.navBar.channels),
                            icon: Badge(
                              isLabelVisible: state.messages.any(
                                (message) =>
                                    (message.type == MessageType.stream &&
                                    message.hasUnreadMessages),
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
                                label: context.t.navBar.allChats,
                                icon: Icon(Icons.chat),
                              ),
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
      ),
    );
  }
}
