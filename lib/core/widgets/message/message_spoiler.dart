import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const double _collapsedWidth = 120;
  static const double _collapsedHeight = 24;
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
    final child = _isRevealed ? _buildRevealed(context) : _buildCollapsed(context);

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
          child: child,
        ),
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const ValueKey('spoiler-collapsed'),
      width: _collapsedWidth,
      height: _collapsedHeight,
      padding: _collapsedPadding,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: _SpoilerText(
        text: widget.content,
        blurSigma: 6,
        maxLines: 1,
      ),
    );
  }

  Widget _buildRevealed(BuildContext context) {
    return _SpoilerText(
      key: const ValueKey('spoiler-revealed'),
      text: widget.content,
    );
  }
}

class _SpoilerText extends StatelessWidget {
  const _SpoilerText({
    super.key,
    required this.text,
    this.blurSigma,
    this.maxLines,
  });

  final String text;
  final double? blurSigma;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sigma = blurSigma ?? 0;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium,
        maxLines: maxLines,
        overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }
}
