import 'package:flutter/material.dart';

class TapEffectIcon extends StatefulWidget {
  const TapEffectIcon({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.padding = const EdgeInsets.all(6.0),
  });

  final Widget child;
  final void Function(TapDownDetails)? onTapDown;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  State<TapEffectIcon> createState() => _TapEffectIconState();
}

class _TapEffectIconState extends State<TapEffectIcon> {
  final double scale = 0.90;
  final double hoverScale = 1.05;
  final duration = const Duration(milliseconds: 90);

  bool _pressed = false;
  bool _hovered = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    widget.onTapDown?.call(details);
  }

  void _onTapUp() => setState(() => _pressed = false);

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final double targetScale = _pressed
        ? scale
        : _hovered
        ? hoverScale
        : 1.0;
    final double targetOpacity = _pressed
        ? 0.6
        : _hovered
        ? 0.85
        : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: (_) => _onTapUp(),
        onTapCancel: () => _onTapCancel(),
        child: AnimatedScale(
          scale: targetScale,
          duration: duration,
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: targetOpacity,
            duration: duration,
            child: Container(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
