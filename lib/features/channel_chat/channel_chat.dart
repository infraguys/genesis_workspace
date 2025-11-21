import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/channel_chat/view/channel_chat_view.dart';

class ChannelChat extends StatelessWidget {
  const ChannelChat({
    super.key,
    required this.channelId,
    this.topicName,
    this.unreadMessagesCount = 0,
    this.leadingOnPressed,
  });

  final int channelId;
  final String? topicName;
  final int? unreadMessagesCount;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return ChannelChatView(
      channelId: channelId,
      topicName: topicName,
      unreadMessagesCount: unreadMessagesCount,
      leadingOnPressed: leadingOnPressed,
    );
  }
}
