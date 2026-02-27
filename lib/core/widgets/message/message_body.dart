import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/message/message_html.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageBody extends StatelessWidget {
  final bool showSenderName;
  final bool isSkeleton;
  final MessageEntity message;
  final bool showTopic;
  final bool isStarred;
  final double maxMessageWidth;
  final Color messageBackgroundColor;
  final Function(String) onSelectedTextChanged;
  const MessageBody({
    super.key,
    required this.showSenderName,
    required this.isSkeleton,
    required this.message,
    required this.showTopic,
    required this.isStarred,
    required this.maxMessageWidth,
    required this.messageBackgroundColor,
    required this.onSelectedTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageColors = Theme.of(context).extension<MessageColors>()!;
    final textColors = Theme.of(context).extension<TextColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSenderName)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  isSkeleton
                      ? Container(
                          height: 10,
                          width: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                        )
                      : Text(
                          message.senderFullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                  if (showTopic && message.subject.isNotEmpty)
                    Skeleton.ignore(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadiusGeometry.circular(14),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                context.read<MessengerCubit>().openChatFromMessage(message);
                              },
                              child: Text(
                                '# ${message.subject}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColors.text30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // if (currentSize(context) > ScreenSize.tablet) ...[
              //   SizedBox(width: 4),
              //   _MessageActions(
              //     isStarred: isStarred,
              //     messageId: message.id,
              //   ),
              // ],
            ],
          ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxMessageWidth, minWidth: 30),
                child: isSkeleton
                    ? Container(
                        height: 14,
                        width: 150,
                        color: theme.colorScheme.surfaceContainerHighest,
                      )
                    : _ExpandableMessageContent(
                        content: message.content,
                        backgroundColor: messageBackgroundColor,
                        onSelectedTextChanged: onSelectedTextChanged,
                      ),
              ),
            ),
            // if (currentSize(context) > ScreenSize.tablet && !showSenderName)
            //   _MessageActions(
            //     isStarred: isStarred,
            //     messageId: message.id,
            //   ),
          ],
        ),
      ],
    );
  }
}

class _ExpandableMessageContent extends StatefulWidget {
  final String content;
  final Color backgroundColor;
  final Function(String) onSelectedTextChanged;

  const _ExpandableMessageContent({
    required this.content,
    required this.backgroundColor,
    required this.onSelectedTextChanged,
  });

  @override
  State<_ExpandableMessageContent> createState() => _ExpandableMessageContentState();
}

class _ExpandableMessageContentState extends State<_ExpandableMessageContent> {
  static const double _collapsedHeight = 500;
  bool _isExpanded = false;
  final GlobalKey _measureKey = GlobalKey();
  bool _measureScheduled = false;
  double? _contentHeight;

  bool get _shouldCollapse => (_contentHeight ?? 0) > (_collapsedHeight + 0.5);

  Widget _buildHtml() {
    return MessageHtml(
      content: widget.content,
      onSelectedTextChanged: widget.onSelectedTextChanged,
    );
  }

  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted) return;
      final RenderObject? renderObject = _measureKey.currentContext?.findRenderObject();
      final RenderBox? box = renderObject is RenderBox ? renderObject : null;
      final double? nextHeight = box?.size.height;
      if (nextHeight == null) return;
      if (_contentHeight == null || (nextHeight - _contentHeight!).abs() > 0.5) {
        setState(() {
          _contentHeight = nextHeight;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ExpandableMessageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      setState(() {
        _isExpanded = false;
        _contentHeight = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasure();
    final bool isCollapsed = !_isExpanded && _shouldCollapse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Offstage(
          offstage: true,
          child: KeyedSubtree(
            key: _measureKey,
            child: _buildHtml(),
          ),
        ),
        isCollapsed
            ? SizedBox(
                height: _collapsedHeight,
                child: ClipRect(
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.backgroundColor.withValues(alpha: 0),
                          widget.backgroundColor.withValues(alpha: 0),
                          widget.backgroundColor.withValues(alpha: 0.98),
                        ],
                        stops: const [0, 0.7, 1],
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: _buildHtml(),
                    ),
                  ),
                ),
              )
            : _buildHtml(),
        if (_shouldCollapse) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text((_isExpanded ? context.t.showLess : context.t.showMore).toUpperCase()),
            ),
          ),
        ],
      ],
    );
  }
}
