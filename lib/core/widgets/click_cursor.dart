import 'package:flutter/material.dart';

class ClickCursor extends StatelessWidget {
  const ClickCursor({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: child,
    );
  }
}
