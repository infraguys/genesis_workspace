import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';

class TopicItem extends StatelessWidget {
  final String topicName;
  final ChannelEntity channel;
  final Widget? trailing;
  final void Function()? onTap;
  const TopicItem({
    super.key,
    required this.topicName,
    required this.channel,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(topicName, overflow: TextOverflow.ellipsis),
        leading: const Icon(Icons.topic),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
