import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/widgets/organization_item.dart';
import 'package:genesis_workspace/core/widgets/out_corners_painter.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
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
      context.read<UpdateCubit>().checkUpdateNeed(),
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
    final theme = Theme.of(context);
    return BlocListener<UpdateCubit, UpdateState>(
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
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 16,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      itemCount: 4,
                                      scrollDirection: Axis.horizontal,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      separatorBuilder: (_, _) {
                                        return SizedBox(width: 16);
                                      },
                                      itemBuilder: (BuildContext context, int index) {
                                        return OrganizationItem(
                                          unreadCount: 1,
                                          imagePath: Assets.images.genesisLogoPng.path,
                                          isSelected: index == 0,
                                          onTap: () {},
                                        );
                                      },
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: Ink(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: InkWell(
                                        onTap: () {},
                                        borderRadius: BorderRadius.circular(8),
                                        mouseCursor: SystemMouseCursors.click,
                                        overlayColor: WidgetStateProperty.resolveWith<Color?>((
                                          states,
                                        ) {
                                          final Color primary = Theme.of(
                                            context,
                                          ).colorScheme.primary;
                                          if (states.contains(WidgetState.pressed)) {
                                            return primary.withValues(
                                              alpha: 0.16,
                                            ); // splash/pressed
                                          }
                                          if (states.contains(WidgetState.hovered)) {
                                            return primary.withValues(alpha: 0.08); // hover
                                          }
                                          return null;
                                        }),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Center(child: Assets.icons.add.svg()),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: AlignmentGeometry.center,
                          child: CustomPaint(
                            painter: OutCornersPainter(backgroundColor: Colors.red),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                              ).copyWith(top: 12, bottom: 8),
                              child: SizedBox(
                                height: 64,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 6,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      height: 64,
                                      width: 64,
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.chat_bubble_outline),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
