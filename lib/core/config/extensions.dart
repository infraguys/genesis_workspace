import 'package:flutter/material.dart';

extension PendingExtension on Widget {
  Widget pending(bool isPending) {
    if (this is! ElevatedButton) return this;

    final ElevatedButton button = this as ElevatedButton;

    return ElevatedButton(
      onPressed: isPending ? null : button.onPressed,
      style: button.style,
      autofocus: button.autofocus,
      clipBehavior: button.clipBehavior,
      focusNode: button.focusNode,
      child: isPending
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : button.child ?? const SizedBox(),
    );
  }
}
