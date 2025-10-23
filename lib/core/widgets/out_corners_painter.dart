import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';

class OutCornersPainter extends CustomPainter {
  OutCornersPainter({
    this.backgroundColor = AppColors.background,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(_defaultCornerRadius),
      topRight: Radius.circular(_defaultCornerRadius),
    ),
  });

  static const double _defaultCornerRadius = 10;

  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final rrect = borderRadius.toRRect(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant OutCornersPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}
