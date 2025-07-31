import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/message_item.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MessagesList extends StatelessWidget {
  final List<MessageEntity> messages;
  final ScrollController? controller;
  final void Function(int id)? onRead;
  final bool showTopic;
  const MessagesList({
    super.key,
    required this.messages,
    this.controller,
    this.onRead,
    this.showTopic = false,
  });

  @override
  Widget build(BuildContext context) {
    final reversedMessages = messages.reversed.toList();
    final UserEntity? _myUser = context.read<ProfileCubit>().state.user;
    return ListView.separated(
      controller: controller,
      reverse: true,
      itemCount: reversedMessages.length - 1,
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
      separatorBuilder: (BuildContext context, int index) {
        final MessageEntity message = reversedMessages[index];
        final MessageEntity nextMessage = reversedMessages[index + 1];

        final bool isNewUser = message.senderId != nextMessage.senderId;
        return SizedBox(height: isNewUser ? 12 : 2);
      },
      itemBuilder: (BuildContext context, int index) {
        final MessageEntity message = reversedMessages[index];
        final MessageEntity nextMessage = reversedMessages[index + 1];
        final MessageEntity? prevMessage = index != 0 ? reversedMessages[index - 1] : null;
        MessageUIOrder messageOrder = MessageUIOrder.middle;

        final bool isNewUser = message.senderId != nextMessage.senderId;
        final bool prevOtherUser = index != 0 && prevMessage?.senderId != message.senderId;
        final bool isMessageMiddle =
            message.senderId == nextMessage.senderId && message.senderId == prevMessage?.senderId;
        final bool isSingle = prevOtherUser && isNewUser;

        if (index == 0) {
          if (isNewUser) {
            messageOrder = MessageUIOrder.lastSingle;
          } else {
            messageOrder = MessageUIOrder.last;
          }
        } else if (isSingle) {
          messageOrder = MessageUIOrder.single;
        } else if (isNewUser) {
          messageOrder = MessageUIOrder.first;
        } else if (isMessageMiddle) {
          messageOrder = MessageUIOrder.middle;
        } else if (prevOtherUser) {
          messageOrder = MessageUIOrder.last;
        }

        final bool isMyMessage = message.senderId == _myUser?.userId;

        return VisibilityDetector(
          key: Key('message-${message.id}'),
          onVisibilityChanged: (info) {
            final visiblePercentage = info.visibleFraction * 100;
            if (visiblePercentage > 50 && (message.flags == null || message.flags!.isEmpty)) {
              if (onRead != null) {
                onRead!(message.id);
              }
            }
          },
          child: MessageItem(
            isMyMessage: isMyMessage,
            message: message,
            messageOrder: messageOrder,
            showTopic: showTopic,
          ),
        );
      },
    );
  }
}
