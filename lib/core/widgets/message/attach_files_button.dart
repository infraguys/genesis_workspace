import 'package:flutter/material.dart';
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

class _AttachFilesButtonState extends State<AttachFilesButton> with SingleTickerProviderStateMixin {
  static OverlayEntry? _menuEntry;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

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
  }

  Future<void> _closeOverlay() async {
    await _controller.reverse();
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _openContextMenu(Offset globalPosition) async {
    if (_menuEntry != null) {
      await _closeOverlay();
    }

    if (!mounted) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);


    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }
    final localInOverlay = overlayBox.globalToLocal(globalPosition);

    const horizontalOffset = 8.0; // shift slightly to the right
    const verticalOffset = -16.0; // place slightly below the tap

    final left = localInOverlay.dx + horizontalOffset;

    double top = localInOverlay.dy - 100 + verticalOffset;

    _menuEntry = OverlayEntry(
      builder: (context) {
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
              left: left,
              top: top,
              child: FadeTransition(
                opacity: _opacity,
                child: ScaleTransition(
                  scale: _scale,
                  alignment: .bottomLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: .circular(8),
                    clipBehavior: .antiAlias,
                    child: Container(
                      width: 220,
                      height: 100,
                      padding: EdgeInsets.all(8),
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
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_menuEntry!);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return TapEffectIcon(
      onTapDown: (details) => _openContextMenu(details.globalPosition),
      child: Assets.icons.attachFile.svg(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
