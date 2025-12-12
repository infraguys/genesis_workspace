import 'package:flutter/material.dart';

class AnimatedOverlay extends StatefulWidget {
  const AnimatedOverlay({
    super.key,
    required this.child,
    required this.closeOverlay,
    required this.alignment,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final Widget child;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Alignment alignment;
  final VoidCallback closeOverlay;

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  Future<void> _closeOverlay() async {
    await _controller.reverse();
    widget.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: .translucent,
            onTap: _closeOverlay,
            onSecondaryTapDown: (_) => _closeOverlay(),
          ),
        ),
        Positioned(
          left: widget.left,
          right: widget.right,
          top: widget.top,
          bottom: widget.bottom,
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              alignment: widget.alignment,
              child: Material(
                elevation: 4.0,
                borderRadius: .circular(8),
                clipBehavior: .antiAlias,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
