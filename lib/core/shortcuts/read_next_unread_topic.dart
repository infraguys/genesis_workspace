import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class NextUnreadTopicIntent extends Intent {
  const NextUnreadTopicIntent();
}

class NextUnreadTopicAction extends Action<NextUnreadTopicIntent> {
  NextUnreadTopicAction({
    required this.isTextInputFocused,
    required this.openNextUnreadTopic,
  });

  final bool Function() isTextInputFocused;
  final Future<void> Function() openNextUnreadTopic;

  @override
  Object? invoke(intent) {
    final keyboard = HardwareKeyboard.instance;
    if (isTextInputFocused()) return null;
    if (keyboard.isAltPressed || keyboard.isControlPressed || keyboard.isMetaPressed) {
      return null;
    }

    unawaited(openNextUnreadTopic());
    return null;
  }
}