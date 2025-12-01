import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

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

extension DmUrl on BuildContext {
  void setDmUserIdInUrl(int? userId) {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = '$userId';

    // Меняем только query — остаёмся на той же странице
    goNamed(Routes.directMessages, queryParameters: queryParams);
  }
}

extension BlocMaybeRead on BuildContext {
  T? maybeRead<T extends StateStreamableSource<Object?>>() {
    try {
      return BlocProvider.of<T>(this, listen: false);
    } catch (_) {
      return null;
    }
  }
}
