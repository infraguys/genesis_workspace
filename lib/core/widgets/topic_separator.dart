import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';

class TopicSeparator extends StatelessWidget {
  final MessageEntity message;

  const TopicSeparator({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color dividerColor = theme.colorScheme.surface;

    return BlocBuilder<MessengerCubit, MessengerState>(
      builder: (context, state) {
        return Row(
          spacing: 16.0,
          children: [
            Expanded(child: Divider(color: dividerColor)),
            TapEffectIcon(
              onTap: () {
                final cubit = context.read<MessengerCubit>();
                cubit.openChatFromMessage(message);
              },
              child: Text(
                '# ${message.subject}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 12.0,
                  color: theme.colorScheme.primary,
                  fontWeight: .w400,
                ),
              ),
            ),
            Expanded(child: Divider(color: dividerColor)),
          ],
        );
      },
    );
  }
}
