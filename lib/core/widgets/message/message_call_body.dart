import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/group_avatars.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageCallBody extends StatelessWidget {
  final MessageEntity message;
  const MessageCallBody({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final messageColors = theme.extension<MessageColors>()!;
    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
        Row(
          spacing: 12,
          children: [
            Text(
              context.t.call.title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.callGreen,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
            Text(
              message.callName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        Row(
          spacing: 16,
          children: [
            Row(
              spacing: 4,
              children: [
                Assets.icons.arrowLeftDown.svg(),
                Text(
                  '0:47',
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColors.text50),
                ),
              ],
            ),
            GroupAvatars(
              bgColor: messageColors.activeCallBackground,
            ),
          ],
        ),
      ],
    );
  }
}
