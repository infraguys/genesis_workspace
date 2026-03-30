import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopAppBar extends StatelessWidget {
  const DesktopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 40,
        width: double.maxFinite,
        child: Row(
          children: [
            Expanded(
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
            WindowButtons(),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonColors = WindowButtonColors(
      iconNormal: theme.colorScheme.primary,
      mouseOver: theme.colorScheme.onPrimary,
      mouseDown: const Color(0xFF805306),
      iconMouseOver: theme.colorScheme.primary,
      iconMouseDown: theme.colorScheme.primary,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: theme.colorScheme.primary,
      iconMouseOver: theme.colorScheme.onSurface,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
