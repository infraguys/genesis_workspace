import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/palettes/palette.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowControls extends StatefulWidget {
  const DesktopWindowControls({super.key});

  @override
  State<DesktopWindowControls> createState() => _DesktopWindowControlsState();
}

class _DesktopWindowControlsState extends State<DesktopWindowControls> with WindowListener {
  bool _isMaximized = false;
  int? _hoveredButtonIndex;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onMaximize(WindowManager windowManager) {
    // Update state if maximize was called externally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isMaximized = true);
      }
    });
  }

  @override
  void onUnmaximize(WindowManager windowManager) {
    // Update state if unmaximize was called externally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isMaximized = false);
      }
    });
  }

  Future<void> _loadWindowState() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
      });
    }
  }

  Future<void> _minimize() async {
    await windowManager.minimize();
  }

  Future<void> _maximizeOrRestore() async {
    // Check state directly, same as double-tap
    final isMaximized = await windowManager.isMaximized();
    if (isMaximized) {
      await windowManager.unmaximize();
      setState(() => _isMaximized = false);
    } else {
      await windowManager.maximize();
      setState(() => _isMaximized = true);
    }
  }

  Future<void> _close() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowControlButton(
          icon: _MinimizeIcon(),
          tooltip: 'Minimize',
          onTap: _minimize,
          index: 0,
          hoveredIndex: _hoveredButtonIndex,
          onHoverChange: (index) => setState(() => _hoveredButtonIndex = index),
        ),
        _WindowControlButton(
          icon: _isMaximized ? _RestoreIcon() : _MaximizeIcon(),
          tooltip: _isMaximized ? 'Restore' : 'Maximize',
          onTap: _maximizeOrRestore,
          index: 1,
          hoveredIndex: _hoveredButtonIndex,
          onHoverChange: (index) => setState(() => _hoveredButtonIndex = index),
        ),
        _WindowControlButton(
          icon: _CloseIcon(),
          tooltip: 'Close',
          onTap: _close,
          index: 2,
          hoveredIndex: _hoveredButtonIndex,
          onHoverChange: (index) => setState(() => _hoveredButtonIndex = index),
          isClose: true,
        ),
      ],
    );
  }
}

class _WindowControlButton extends StatelessWidget {
  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.index,
    required this.hoveredIndex,
    required this.onHoverChange,
    this.isClose = false,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onTap;
  final int index;
  final int? hoveredIndex;
  final ValueChanged<int?> onHoverChange;
  final bool isClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    final isHovered = hoveredIndex == index;
    final backgroundColor = isClose && isHovered ? const Color(0xFFE81123) : (isHovered ? theme.colorScheme.onSurface.withOpacity(0.1) : Colors.transparent);
    final iconColor = isClose && isHovered ? Colors.white : textColors.text100;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChange(index),
      onExit: (_) => onHoverChange(null),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _MinimizeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;
    return CustomPaint(
      size: const Size(10, 1),
      painter: _MinimizePainter(color: textColors.text100),
    );
  }
}

class _MinimizePainter extends CustomPainter {
  final Color color;
  _MinimizePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MaximizeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;
    return CustomPaint(
      size: const Size(10, 10),
      painter: _MaximizePainter(color: textColors.text100),
    );
  }
}

class _MaximizePainter extends CustomPainter {
  final Color color;
  _MaximizePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(1));
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RestoreIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;
    return CustomPaint(
      size: const Size(10, 10),
      painter: _RestorePainter(color: textColors.text100),
    );
  }
}

class _RestorePainter extends CustomPainter {
  final Color color;
  _RestorePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Back square (offset right-up)
    final outerRect = Rect.fromLTWH(2, 2, size.width - 2, size.height - 2);
    canvas.drawRect(outerRect, paint);

    // Front square (offset left-down)
    final innerRect = Rect.fromLTWH(0, 0, size.width - 2, size.height - 2);
    canvas.drawRect(innerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloseIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;
    return CustomPaint(
      size: const Size(10, 10),
      painter: _ClosePainter(color: textColors.text100),
    );
  }
}

class _ClosePainter extends CustomPainter {
  final Color color;
  _ClosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
