import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_action.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AttachFilesButton extends StatefulWidget {
  const AttachFilesButton({
    super.key,
    required this.attachmentsKey,
    required this.onUploadFile,
    required this.onUploadImage,
  });

  final GlobalKey<CustomPopupState> attachmentsKey;
  final VoidCallback onUploadFile;
  final VoidCallback onUploadImage;

  @override
  State<AttachFilesButton> createState() => _AttachFilesButtonState();
}

class _AttachFilesButtonState extends State<AttachFilesButton> {
  static OverlayEntry? _menuEntry;

  void _closeOverlay() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _openContextMenu(BuildContext context, Offset globalPosition) {
    _closeOverlay();

    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }

    final localInOverlay = overlayBox.globalToLocal(globalPosition);

    const horizontalOffset = 8.0; // shift slightly to the right
    const verticalOffset = 8.0;   // place slightly below the tap

    final left = localInOverlay.dx + horizontalOffset;

    // сначала пробуем открыть меню под кнопкой
    double top = localInOverlay.dy + verticalOffset;
    const menuHeight = 100.0;
    final screenHeight = overlayBox.size.height;

    // если меню не влезает снизу — открываем его над кнопкой
    if (top + menuHeight > screenHeight) {
      top = localInOverlay.dy - menuHeight - verticalOffset;
    }

    _menuEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeOverlay,
                onSecondaryTapDown: (_) => _closeOverlay(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: 220,
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                // constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AttachmentAction(
                      iconData: Icons.insert_drive_file_rounded,
                      label: context.t.attachmentButton.file,
                      onTap: () {
                        widget.onUploadFile();
                        _closeOverlay();
                      },
                    ),
                    const SizedBox(height: 4),
                    AttachmentAction(
                      iconData: Icons.image_outlined,
                      label: context.t.attachmentButton.image,
                      onTap: () {
                        widget.onUploadImage();
                        _closeOverlay();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_menuEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return GestureDetector(
      onTapDown: (details) => _openContextMenu(context, details.globalPosition),
      child: Assets.icons.attachFile.svg(),
    );
    ;
  }
}
