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

final buttonColors = WindowButtonColors(
  iconNormal: const Color(0xFF805306),
  mouseOver: const Color(0xFFF6A00C),
  mouseDown: const Color(0xFF805306),
  iconMouseOver: const Color(0xFF805306),
  iconMouseDown: const Color(0xFFFFD500),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color(0xFF805306),
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
