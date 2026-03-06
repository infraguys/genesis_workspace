import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/widgets/animated_overlay.dart';

class ChatContextMenuOverlay {
  static OverlayEntry? _entry;

  static void close() {
    _entry?.remove();
    _entry = null;
  }

  static void show({
    required BuildContext context,
    required Offset globalPosition,
    required Widget child,
    double width = 270,
    double itemHeight = 36,
    double itemSpacing = 4,
    double padding = 8,
  }) {
    close();

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;

    if (overlayBox == null) return;

    final local = overlayBox.globalToLocal(globalPosition);
    final screenSize = MediaQuery.sizeOf(context);
    final estimatedHeight = itemHeight + itemSpacing + (padding * 2);
    final openDown = (screenSize.height - local.dy - padding) > estimatedHeight;

    final left = local.dx.clamp(
      padding,
      screenSize.width - width - padding,
    );

    _entry = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        return AnimatedOverlay(
          left: left,
          top: openDown ? local.dy : null,
          bottom: openDown ? null : (screenSize.height - local.dy),
          alignment: openDown ? Alignment.topLeft : Alignment.bottomLeft,
          closeOverlay: close,
          child: Container(
            width: width,
            padding: const .symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: .circular(8),
            ),
            child: child,
          ),
        );
      },
    );

    overlay.insert(_entry!);
  }
}