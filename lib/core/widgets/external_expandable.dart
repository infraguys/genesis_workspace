import 'package:flutter/material.dart';

class ExternalExpandable extends StatefulWidget {
  const ExternalExpandable({
    super.key,
    required this.isExpanded,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.topCenter,
  });

  final bool isExpanded;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  @override
  State<ExternalExpandable> createState() => _ExternalExpandableState();
}

class _ExternalExpandableState extends State<ExternalExpandable> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isExpanded ? 1 : 0,
    );

    _sizeFactor = CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    );
  }

  @override
  void didUpdateWidget(covariant ExternalExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }

    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    if (oldWidget.curve != widget.curve) {
      _sizeFactor = CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        axisAlignment: -1,
        sizeFactor: _sizeFactor,
        child: Align(
          alignment: widget.alignment,
          child: widget.child,
        ),
      ),
    );
  }
}
