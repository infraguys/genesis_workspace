import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/call/view/call_web_view.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class DraggableResizableCallModal extends StatefulWidget {
  const DraggableResizableCallModal({
    super.key,
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
  State<DraggableResizableCallModal> createState() => _DraggableResizableCallModalState();
}

class _DraggableResizableCallModalState extends State<DraggableResizableCallModal> {
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
                              onPanUpdate: widget.isFullscreen
                                  ? null
                                  : (details) => _onDrag(details, constraints, padding),
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
                                    Text(context.t.call.title, style: theme.textTheme.titleMedium),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: widget.isMinimized ? widget.onRestore : widget.onMinimize,
                                      icon: Icon(
                                        widget.isMinimized ? Icons.unfold_more_rounded : Icons.minimize_rounded,
                                      ),
                                      tooltip: widget.isMinimized ? context.t.call.restore : context.t.call.minimize,
                                    ),
                                    IconButton(
                                      onPressed: widget.onToggleFullscreen,
                                      icon: Icon(
                                        widget.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                                      ),
                                      tooltip: widget.isFullscreen
                                          ? context.t.call.exitFullscreen
                                          : context.t.call.fullscreen,
                                    ),
                                    IconButton(
                                      onPressed: widget.onClose,
                                      icon: const Icon(Icons.close_rounded),
                                      tooltip: context.t.general.close,
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
                                        title: context.t.call.title,
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
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeDownRight,
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
