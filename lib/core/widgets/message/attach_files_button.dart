import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/message/attachment_action.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AttachFilesButton extends StatelessWidget {
  final GlobalKey<CustomPopupState> attachmentsKey;
  final VoidCallback onUploadFile;
  final VoidCallback onUploadImage;
  const AttachFilesButton({
    super.key,
    required this.attachmentsKey,
    required this.onUploadFile,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return CustomPopup(
      key: attachmentsKey,
      isLongPress: true,
      showArrow: false,
      contentPadding: EdgeInsets.zero,
      contentRadius: 12,
      backgroundColor: theme.colorScheme.surface,
      content: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AttachmentAction(
              iconData: Icons.insert_drive_file_rounded,
              label: context.t.attachmentButton.file,
              onTap: () {
                Navigator.of(context).pop();
                onUploadFile();
              },
            ),
            const SizedBox(height: 4),
            AttachmentAction(
              iconData: Icons.image_outlined,
              label: context.t.attachmentButton.image,
              onTap: () {
                Navigator.of(context).pop();
                onUploadImage();
              },
            ),
          ],
        ),
      ),
      child: IconButton(
        onPressed: () => attachmentsKey.currentState?.show(),
        icon: Assets.icons.attachFile.svg(
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            textColors.text30,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
