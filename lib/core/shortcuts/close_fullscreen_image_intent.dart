import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class CloseFullscreenImageIntent extends Intent {
  const CloseFullscreenImageIntent();
}

class CloseFullscreenImageAction extends ContextAction {
  @override
  Object? invoke(Intent intent, [BuildContext? context]) {
    context!.pop();

    return null;
  }
}
