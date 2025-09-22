import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

import 'attachment_image/attachment_image_provider.dart';

class AttachmentTile extends StatefulWidget {
  final UploadFileEntity file;
  final String extension;
  final int fileSize;
  final VoidCallback? onRemove;
  final VoidCallback? onCancelUploading;

  final bool isUploading;
  final int? bytesSent;
  final int? bytesTotal;

  const AttachmentTile({
    super.key,
    required this.file,
    required this.extension,
    required this.fileSize,
    this.onRemove,
    this.onCancelUploading,
    this.isUploading = false,
    this.bytesSent,
    this.bytesTotal,
  });

  @override
  State<AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<AttachmentTile> {
  String? _cachedPreviewPath;
  bool isImage = false;
  String? effectivePath;
  ImageProvider? previewImage;

  @override
  void initState() {
    super.initState();
    if (widget.file.type == UploadFileType.image &&
        widget.file.path != null &&
        widget.file.path!.isNotEmpty) {
      _cachedPreviewPath = widget.file.path!;
    }
    isImage = widget.file.type == UploadFileType.image;

    effectivePath = isImage
        ? ((widget.file.path != null && widget.file.path!.isNotEmpty)
              ? widget.file.path
              : _cachedPreviewPath)
        : null;

    previewImage =
        (isImage &&
            ((effectivePath != null && effectivePath!.isNotEmpty) || widget.file.bytes.isNotEmpty))
        ? createAttachmentImageProvider(path: effectivePath, bytes: widget.file.bytes)
        : null;
  }

  @override
  void didUpdateWidget(covariant AttachmentTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.file.localId != oldWidget.file.localId) {
      _cachedPreviewPath = widget.file.type == UploadFileType.image ? widget.file.path : null;
      return;
    }

    if (widget.file.type == UploadFileType.image &&
        widget.file.path != null &&
        widget.file.path!.isNotEmpty &&
        widget.file.path != oldWidget.file.path) {
      _cachedPreviewPath = widget.file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double? progressValue = _computeProgress(widget.bytesSent, widget.bytesTotal);
    final String? percentText = progressValue != null
        ? '${(progressValue * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : null;

    return GestureDetector(
      onTap: () {
        if (isImage) {
          context.pushNamed(Routes.imageFullScreen, extra: widget.file.bytes);
        }
      },
      child: MouseRegion(
        cursor: isImage ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: 96,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Stack(
            children: [
              if (previewImage != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: widget.file.bytes.toString(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: previewImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (previewImage == null)
                        (isImage
                            ? Icon(
                                Icons.image_outlined,
                                size: 28,
                                color: theme.colorScheme.onSurfaceVariant,
                              )
                            : Text(
                                widget.extension.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              )),
                      if (!isImage)
                        Text(
                          formatFileSize(widget.fileSize),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!isImage)
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: Text(
                    widget.file.filename,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
              if (widget.isUploading)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: theme.colorScheme.surface.withOpacity(0.65),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: progressValue,
                                ),
                              ),
                              if (percentText != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  percentText,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: widget.isUploading ? widget.onCancelUploading : widget.onRemove,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isUploading ? Icons.stop_rounded : Icons.close_rounded,
                      size: 14,
                      color: widget.isUploading
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _computeProgress(int? sent, int? total) {
    if (sent == null || total == null || total <= 0) return null;
    final double value = sent / total;
    if (value.isNaN || value.isInfinite) return null;
    return value.clamp(0.0, 1.0);
  }
}
