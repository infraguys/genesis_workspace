import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/features/app_bar/view/scaffold_desktop_app_bar.dart';
import 'package:genesis_workspace/features/authentication/presentation/auth.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/call/view/call_web_view.dart';
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

  Widget _buildMobileBottomNavigationBar(
    BuildContext context,
    ThemeData theme,
    TextColors textColors,
  ) {
    final Color selectedIconColor = textColors.text100;
    final Color unselectedIconColor = textColors.text30;
    final Color selectedBackgroundColor = theme.colorScheme.onSurface.withOpacity(0.05);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _goBranch,
        selectedItemColor: selectedIconColor,
        unselectedItemColor: unselectedIconColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          for (final model in branchModels)
            BottomNavigationBarItem(
              label: model.title(context),
              icon: _buildNavigationIcon(
                icon: model.icon,
                iconColor: unselectedIconColor,
                backgroundColor: Colors.transparent,
              ),
              activeIcon: _buildNavigationIcon(
                icon: model.icon,
                iconColor: selectedIconColor,
                backgroundColor: selectedBackgroundColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationIcon({
    required SvgGenImage icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: icon.svg(
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }

  Future<void> getInitialData() async {
    await context.read<RealTimeCubit>().init();

    await Future.wait([
      context.read<UpdateCubit>().checkUpdateNeed(),
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
        break;
      case AppLifecycleState.resumed:
        await context.read<RealTimeCubit>().ensureConnection();
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final screenSize = currentSize(context);
    final bool isTabletOrSmaller = screenSize <= ScreenSize.tablet;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, current) => prev.isAuthorized != current.isAuthorized,
      listener: (context, state) {
        setState(() {
          _future = getInitialData();
        });
      },
      child: BlocListener<UpdateCubit, UpdateState>(
        listener: (context, updateState) {
          if (updateState.isUpdateRequired) {
            context.goNamed(Routes.forceUpdate);
          }
        },
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            return BlocBuilder<CallCubit, CallState>(
              builder: (context, callState) {
                return Stack(
                  children: [
                    Scaffold(
                      bottomNavigationBar: isTabletOrSmaller
                          ? _buildMobileBottomNavigationBar(context, theme, textColors)
                          : null,
                      body: snapshot.connectionState == .waiting
                          ? Center(child: CircularProgressIndicator())
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                Column(
                                  spacing: 4.0,
                                  children: [
                                    if (!isTabletOrSmaller)
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
                              ],
                            ),
                    ),
                    if (callState.isCallActive)
                      _DraggableResizableCallModal(
                        meetingLink: callState.meetUrl,
                        isMinimized: callState.isMinimized,
                        isFullscreen: callState.isFullscreen,
                        dockRect: callState.dockRect,
                        onClose: () => context.read<CallCubit>().closeCall(),
                        onMinimize: () => context.read<CallCubit>().minimizeCall(),
                        onRestore: () => context.read<CallCubit>().restoreCall(),
                        onToggleFullscreen: () => context.read<CallCubit>().toggleFullscreen(),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DraggableResizableCallModal extends StatefulWidget {
  const _DraggableResizableCallModal({
    required this.meetingLink,
    required this.isMinimized,
    required this.isFullscreen,
    required this.dockRect,
    required this.onClose,
    required this.onMinimize,
    required this.onRestore,
    required this.onToggleFullscreen,
  });

  final String meetingLink;
  final bool isMinimized;
  final bool isFullscreen;
  final Rect? dockRect;
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final VoidCallback onRestore;
  final VoidCallback onToggleFullscreen;

  @override
  State<_DraggableResizableCallModal> createState() => _DraggableResizableCallModalState();
}

class _DraggableResizableCallModalState extends State<_DraggableResizableCallModal> {
  static const Size _minSize = Size(360, 260);
  static const Size _minimizedSize = Size(220, 60);
  static const Size _hiddenSize = Size(1, 1);
  static const double _headerHeight = 52;
  static const double _edgePadding = 16;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  late Offset _position;
  late Size _size;
  bool _isInitialized = false;

  void _initializeIfNeeded(BoxConstraints constraints, EdgeInsets padding) {
    if (_isInitialized) return;

    final double maxWidth = math.max(1, constraints.maxWidth - padding.horizontal - _edgePadding * 2);
    final double maxHeight = math.max(1, constraints.maxHeight - padding.vertical - _edgePadding * 2);

    final double width = (maxWidth * 0.55).clamp(
      math.min(_minSize.width, maxWidth),
      math.max(_minSize.width, maxWidth),
    );
    final double height = (maxHeight * 0.6).clamp(
      math.min(_minSize.height, maxHeight),
      math.max(_minSize.height, maxHeight),
    );

    _size = Size(width, height);
    _position = Offset(
      padding.left + _edgePadding + (maxWidth - width) / 2,
      padding.top + _edgePadding + (maxHeight - height) / 2,
    );

    _isInitialized = true;
  }

  Offset _clampPosition(
    Offset candidate,
    Size modalSize,
    BoxConstraints constraints,
    EdgeInsets padding,
  ) {
    final double minX = padding.left + _edgePadding;
    final double minY = padding.top + _edgePadding;
    final double maxX = constraints.maxWidth - modalSize.width - padding.right - _edgePadding;
    final double maxY = constraints.maxHeight - modalSize.height - padding.bottom - _edgePadding;

    return Offset(
      candidate.dx.clamp(minX, math.max(minX, maxX)),
      candidate.dy.clamp(minY, math.max(minY, maxY)),
    );
  }

  Size _clampSize(Size current, BoxConstraints constraints, EdgeInsets padding) {
    final double maxWidth = math.max(1, constraints.maxWidth - padding.horizontal - _edgePadding * 2);
    final double maxHeight = math.max(1, constraints.maxHeight - padding.vertical - _edgePadding * 2);

    final double width = current.width.clamp(
      math.min(_minSize.width, maxWidth),
      math.max(_minSize.width, maxWidth),
    );
    final double height = current.height.clamp(
      math.min(_minSize.height, maxHeight),
      math.max(_minSize.height, maxHeight),
    );

    return Size(width, height);
  }

  void _onDrag(DragUpdateDetails details, BoxConstraints constraints, EdgeInsets padding) {
    setState(() {
      _position = _clampPosition(_position + details.delta, _size, constraints, padding);
    });
  }

  void _onResize(DragUpdateDetails details, BoxConstraints constraints, EdgeInsets padding) {
    final Size resized = _clampSize(
      Size(_size.width + details.delta.dx, _size.height + details.delta.dy),
      constraints,
      padding,
    );

    setState(() {
      _size = resized;
      _position = _clampPosition(_position, _size, constraints, padding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = MediaQuery.of(context).padding;
        _initializeIfNeeded(constraints, padding);

        final Size boundedSize = _clampSize(_size, constraints, padding);
        if (boundedSize != _size) {
          _size = boundedSize;
        }
        final Offset boundedPosition = _clampPosition(_position, _size, constraints, padding);
        if (boundedPosition != _position) {
          _position = boundedPosition;
        }

        final Size fullscreenSize = Size(
          math.max(1, constraints.maxWidth - padding.horizontal - _edgePadding * 2),
          math.max(1, constraints.maxHeight - padding.vertical - _edgePadding * 2),
        );

        final bool hasDockTarget = widget.isMinimized && widget.dockRect != null;
        final Size targetSize = widget.isMinimized
            ? (hasDockTarget ? widget.dockRect!.size : _hiddenSize)
            : widget.isFullscreen
                ? fullscreenSize
                : _size;

        final Offset targetPosition = widget.isMinimized && widget.dockRect != null
            ? widget.dockRect!.topLeft
            : widget.isFullscreen
                ? Offset(padding.left + _edgePadding, padding.top + _edgePadding)
                : _clampPosition(_position, targetSize, constraints, padding);

        final double targetOpacity = widget.isMinimized ? 0 : 1;

        return Stack(
          children: [
            if (!widget.isMinimized)
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withOpacity(0.25),
              ),
            AnimatedPositioned(
              duration: _animationDuration,
              curve: Curves.easeOutCubic,
              left: targetPosition.dx,
              top: targetPosition.dy,
              width: targetSize.width,
              height: targetSize.height,
              child: IgnorePointer(
                ignoring: widget.isMinimized,
                child: AnimatedOpacity(
                  duration: _animationDuration,
                  curve: Curves.easeOutCubic,
                  opacity: targetOpacity,
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    color: theme.colorScheme.surface,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate:
                                  widget.isFullscreen ? null : (details) => _onDrag(details, constraints, padding),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10).copyWith(bottom: 0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.call_rounded,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Call', style: theme.textTheme.titleMedium),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: widget.isMinimized ? widget.onRestore : widget.onMinimize,
                                      icon: Icon(
                                        widget.isMinimized ? Icons.unfold_more_rounded : Icons.minimize_rounded,
                                      ),
                                      tooltip: widget.isMinimized ? 'Restore' : 'Minimize',
                                    ),
                                    IconButton(
                                      onPressed: widget.onToggleFullscreen,
                                      icon: Icon(
                                        widget.isFullscreen
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
                                      ),
                                      tooltip: widget.isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
                                    ),
                                    IconButton(
                                      onPressed: widget.onClose,
                                      icon: const Icon(Icons.close_rounded),
                                      tooltip: 'Close',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            ClipRect(
                              child: AnimatedOpacity(
                                duration: _animationDuration,
                                curve: Curves.easeOutCubic,
                                opacity: widget.isMinimized ? 0 : 1,
                                child: AnimatedSize(
                                  duration: _animationDuration,
                                  curve: Curves.easeOutCubic,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: math.max(0, targetSize.height - _headerHeight - 1),
                                    child: IgnorePointer(
                                      ignoring: widget.isMinimized,
                                      child: CallWebView(
                                        meetingLink: widget.meetingLink,
                                        showHeader: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!widget.isFullscreen && !widget.isMinimized)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (details) => _onResize(details, constraints, padding),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.open_in_full_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
