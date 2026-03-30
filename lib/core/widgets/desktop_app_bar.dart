import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopAppBar extends StatelessWidget {
  const DesktopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 40,
          width: double.maxFinite,
          child: MoveWindow(
            onDoubleTap: () async {
              final isMaximized = await windowManager.isMaximized();
              if (isMaximized) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
          ),
        ),
      ),
    );
  }
}
