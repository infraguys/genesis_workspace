import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/animated_overlay.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_action.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AttachFilesButton extends StatefulWidget {
  const AttachFilesButton({
    super.key,
    required this.onUploadFile,
    required this.onUploadImage,
  });

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

  void _openContextMenu(Offset globalPosition) async {
    _closeOverlay();

    if (!mounted) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }
    final localInOverlay = overlayBox.globalToLocal(globalPosition);

    const horizontalOffset = 8.0;
    const verticalOffset = -16.0;

    final left = localInOverlay.dx + horizontalOffset;
    final top = localInOverlay.dy - 100 + verticalOffset;

    _menuEntry = OverlayEntry(
      builder: (context) {
        return AnimatedOverlay(
          left: left,
          top: top,
          alignment: .bottomLeft,
          closeOverlay: _closeOverlay,
          child: Container(
            width: 220,
            height: 100,
            padding: .all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
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
        );
      },
    );

    overlay.insert(_menuEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColors = theme.extension<IconColors>()!;
    return TapEffectIcon(
      onTapDown: (details) => _openContextMenu(details.globalPosition),
      child: Assets.icons.attachFile.svg(
        colorFilter: ColorFilter.mode(
          iconColors.base,
          .srcIn,
        ),
      ),
    );
  }
}
