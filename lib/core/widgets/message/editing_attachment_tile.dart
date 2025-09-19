import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/authorized_image.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';

class EditingAttachmentTile extends StatelessWidget {
  final EditingAttachment attachment;
  final VoidCallback? onRemove;

  const EditingAttachmentTile({super.key, required this.attachment, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isImage = attachment.type == UploadFileType.image;

    return Container(
      width: 84, // уже по ширине, чем твои 96
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          if (isImage)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AuthorizedImage(
                  url: '${AppConstants.baseUrl}${attachment.url}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isImage)
                    Text(
                      attachment.extension.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
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
                attachment.filename,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
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
                child: Icon(Icons.delete_outline_rounded, size: 14, color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
