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

class _MessageSpoilerState extends State<MessageSpoiler> {
  bool _isRevealed = false;

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isRevealed
            ? _SpoilerText(
                key: const ValueKey('spoiler-clear'),
                text: widget.content,
              )
            : _SpoilerText(
                key: const ValueKey('spoiler-blur'),
                text: widget.content,
                blurSigma: 6,
              ),
      ),
    );
  }
}

class _SpoilerText extends StatelessWidget {
  const _SpoilerText({
    super.key,
    required this.text,
    this.blurSigma,
  });

  final String text;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sigma = blurSigma ?? 0;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
