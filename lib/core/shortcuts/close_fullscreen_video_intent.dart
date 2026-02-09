import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class CloseFullscreenVideoIntent extends Intent {
  const CloseFullscreenVideoIntent();
}

class CloseFullscreenVideoAction extends ContextAction {
  @override
  Object? invoke(Intent intent, [BuildContext? context]) {
    context!.pop();

    return null;
  }
}
