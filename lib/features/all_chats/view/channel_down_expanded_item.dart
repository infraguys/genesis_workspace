import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChannelDownExpandedItem extends StatefulWidget {
  final ChannelEntity channel;
  final VoidCallback? onTap;
  final void Function(TopicEntity topic)? onTopicTap;

  const ChannelDownExpandedItem({super.key, required this.channel, this.onTap, this.onTopicTap});

  @override
  State<ChannelDownExpandedItem> createState() => _ChannelDownExpandedItemState();
}

class _ChannelDownExpandedItemState extends State<ChannelDownExpandedItem>
    with TickerProviderStateMixin {
  bool isExpanded = false;
  late final Color channelColor;

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeInOut;

  void _handleHeaderTap() {
    final bool wasExpanded = isExpanded;
    setState(() => isExpanded = !isExpanded);
    if (!wasExpanded) {
      if (widget.onTap != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onTap!.call();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    channelColor = parseColor(widget.channel.color);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle channelTextStyle = Theme.of(context).textTheme.bodyLarge!;
    final TextStyle topicTextStyle = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _handleHeaderTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(width: 3, height: 24, color: channelColor),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: _animationDuration,
                    curve: _animationCurve,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '# ${widget.channel.name}',
                      style: channelTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: _animationDuration,
            curve: _animationCurve,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Skeletonizer(
                      enabled: widget.channel.topics.isEmpty,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.channel.topics.isEmpty ? 3 : widget.channel.topics.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (widget.channel.topics.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text('• topic.name', style: topicTextStyle),
                            );
                          } else {
                            final TopicEntity topic = widget.channel.topics[index];
                            return InkWell(
                              onTap: () => widget.onTopicTap?.call(topic),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text('• ${topic.name}', style: topicTextStyle),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }
}
