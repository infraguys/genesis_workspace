import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/features/authentication/presentation/auth.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/desktop_app_bar/view/scaffold_desktop_app_bar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/navigation/app_shell_controller.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_idle_detector/in_app_idle_detector.dart';

class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() => _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState extends State<ScaffoldWithNestedNavigation> with WidgetsBindingObserver {
  Future<void>? _future;
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

  Future<void> getInitialData() async {
    await Future.wait([
      context.read<UpdateCubit>().checkUpdateNeed(),
      context.read<RealTimeCubit>().init(),
      context.read<ProfileCubit>().getOwnUser(),
    ]);
  }

  @override
  void initState() {
    appShellController = getIt<AppShellController>();
    appShellController.attach(widget.navigationShell);
    _initIdleDetector();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) BrowserContextMenu.disableContextMenu();
    _future = getInitialData();
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
      case AppLifecycleState.resumed:
        await context.read<RealTimeCubit>().ensureConnection();
      // print("resumed");
      case AppLifecycleState.detached:
      // print("detached");
      case AppLifecycleState.paused:
      // print("paused");
      case AppLifecycleState.hidden:
      // print("hidden");
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, current) => prev.isAuthorized != current.isAuthorized,
      listener: (context, state) {
        setState(() {
          _future = getInitialData();
        });
      },
      child: BlocListener<UpdateCubit, UpdateState>(
        listener: (context, state) {
          if (state.isUpdateRequired) {
            context.goNamed(Routes.forceUpdate);
          }
        },
        child: FutureBuilder(
          future: _future,
          builder: (context, asyncSnapshot) {
            return Scaffold(
              body: Column(
                spacing: 4.0,
                children: [
                  ScaffoldDesktopAppBar(
                    onSelectBranch: _goBranch,
                    selectedIndex: widget.navigationShell.currentIndex,
                  ),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (prev, current) => prev.isAuthorized != current.isAuthorized,
                    builder: (_, state) {
                      return Expanded(child: state.isAuthorized ? widget.navigationShell : Auth());
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
