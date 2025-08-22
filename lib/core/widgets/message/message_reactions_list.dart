import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';

class MessageReactionsList extends StatelessWidget {
  final MessageEntity message;
  final int myUserId;
  final double maxWidth;
  const MessageReactionsList({
    super.key,
    required this.message,
    required this.myUserId,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: SizedBox(
        width: maxWidth,
        child: Wrap(
          spacing: 6.0,
          runSpacing: 4.0,
          children: message.aggregatedReactions.entries.map((entry) {
            final ReactionDetails reaction = entry.value;
            final bool isMyReaction = reaction.userIds.contains(myUserId);

            return GestureDetector(
              onTap: () async {
                final String emojiIdentifier = entry.key;
                if (isMyReaction) {
                  await context.read<MessagesCubit>().removeEmojiReaction(
                    message.id,
                    emojiName: emojiIdentifier,
                  );
                } else {
                  await context.read<MessagesCubit>().addEmojiReaction(
                    message.id,
                    emojiName: emojiIdentifier,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMyReaction ? theme.colorScheme.primaryFixedDim : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isMyReaction
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UnicodeEmojiWidget(
                      emojiDisplay: UnicodeEmojiDisplay(
                        emojiName: reaction.emojiName,
                        emojiUnicode: reaction.emojiCode,
                      ),
                      size: 16,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      reaction.count.toString(),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: isMyReaction ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
