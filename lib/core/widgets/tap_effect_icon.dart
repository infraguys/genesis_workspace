import 'package:flutter/material.dart';

class TapEffectIcon extends StatefulWidget {
  const TapEffectIcon({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
  });

  final Widget child;
  final void Function(TapDownDetails)? onTapDown;
  final VoidCallback? onTap;

  @override
  State<TapEffectIcon> createState() => _TapEffectIconState();
}

class _TapEffectIconState extends State<TapEffectIcon> {
  final double scale = 0.90;
  final duration = const Duration(milliseconds: 90);

  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    widget.onTapDown?.call(details);
  }

  void _onTapUp() => setState(() => _pressed = false);

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: (_) => _onTapUp(),
        onTapCancel: () => _onTapCancel(),
        child: AnimatedScale(
          scale: _pressed ? scale : 1.0,
          duration: duration,
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.6 : 1.0,
            duration: duration,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
