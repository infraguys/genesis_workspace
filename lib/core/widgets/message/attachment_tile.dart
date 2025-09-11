import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';

class AttachmentTile extends StatelessWidget {
  final String filename;
  final String extension;
  final int fileSize;
  final VoidCallback? onRemove;

  // добавлено:
  final bool isUploading;
  final int? bytesSent;
  final int? bytesTotal;

  const AttachmentTile({
    super.key,
    required this.filename,
    required this.extension,
    required this.fileSize,
    this.onRemove,
    this.isUploading = false,
    this.bytesSent,
    this.bytesTotal,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isImage = isImageExtension(extension);

    final double? progressValue = _computeProgress(bytesSent, bytesTotal);
    final String? percentText = progressValue != null
        ? '${(progressValue * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : null;

    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          // Контент плитки
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isImage
                      ? Icon(
                          Icons.image_outlined,
                          size: 28,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : Text(
                          extension.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                  Text(
                    formatFileSize(fileSize),
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

          // Имя файла — снизу по центру
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: Text(
              filename,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),

          // Кнопка закрытия — справа сверху
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
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
                  Icons.close_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Оверлей прогресса загрузки
          if (isUploading)
            Positioned.fill(
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
                            value: progressValue, // null => indeterminate
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
        ],
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
