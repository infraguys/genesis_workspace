import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageSpoiler extends StatefulWidget {
  const MessageSpoiler({
    super.key,
    required this.content,
  });

  final String content;

  @override
  State<MessageSpoiler> createState() => _MessageSpoilerState();
}

class _MessageSpoilerState extends State<MessageSpoiler> with TickerProviderStateMixin {
  // static const double _collapsedWidth = 120;
  static const double _collapsedHeight = 30;
  static const EdgeInsets _collapsedPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  bool _isRevealed = false;

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextColors textColors = theme.extension<TextColors>()!;
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSize(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.hardEdge,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _isRevealed
              ? Padding(
                  key: const ValueKey('spoiler-revealed'),
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: theme.dividerColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: _SpoilerText(
                      text: widget.content,
                    ),
                  ),
                )
              : Container(
                  key: const ValueKey('spoiler-collapsed'),
                  padding: _collapsedPadding,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      context.t.showSpoiler,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: .underline,
                        color: textColors.text50,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SpoilerText extends StatelessWidget {
  const _SpoilerText({
    super.key,
    required this.text,
    this.maxLines,
  });

  final String text;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }
}
