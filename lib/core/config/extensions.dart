import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

extension PendingExtension on Widget {
  Widget pending(bool isPending) {
    if (this is ElevatedButton) {
      final ElevatedButton button = this as ElevatedButton;

      return ElevatedButton(
        key: button.key,
        onPressed: isPending ? null : button.onPressed,
        onLongPress: isPending ? null : button.onLongPress,
        style: button.style,
        autofocus: button.autofocus,
        clipBehavior: button.clipBehavior,
        focusNode: button.focusNode,
        statesController: button.statesController,
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

    if (this is FilledButton) {
      final FilledButton button = this as FilledButton;

      return FilledButton(
        key: button.key,
        onPressed: isPending ? null : button.onPressed,
        onLongPress: isPending ? null : button.onLongPress,
        style: button.style,
        autofocus: button.autofocus,
        clipBehavior: button.clipBehavior,
        focusNode: button.focusNode,
        statesController: button.statesController,
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

    if (this is TextButton) {
      final TextButton button = this as TextButton;

      return TextButton(
        key: button.key,
        onPressed: isPending ? null : button.onPressed,
        onLongPress: isPending ? null : button.onLongPress,
        style: button.style,
        autofocus: button.autofocus,
        clipBehavior: button.clipBehavior,
        focusNode: button.focusNode,
        statesController: button.statesController,
        child: isPending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            : button.child ?? const SizedBox(),
      );
    }

    if (this is IconButton) {
      final IconButton button = this as IconButton;

      return IconButton(
        key: button.key,
        onPressed: isPending ? null : button.onPressed,
        iconSize: button.iconSize,
        padding: button.padding,
        alignment: button.alignment,
        splashRadius: button.splashRadius,
        color: button.color,
        focusColor: button.focusColor,
        hoverColor: button.hoverColor,
        highlightColor: button.highlightColor,
        splashColor: button.splashColor,
        disabledColor: button.disabledColor,
        focusNode: button.focusNode,
        tooltip: button.tooltip,
        enableFeedback: button.enableFeedback,
        constraints: button.constraints,
        style: button.style,
        icon: isPending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : button.icon,
      );
    }

    return this;
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

extension TextThemeLetterSpacingX on TextTheme {
  TextTheme withLetterSpacing(double letterSpacing) {
    TextStyle? applyTo(TextStyle? style) => style?.copyWith(letterSpacing: letterSpacing);

    return copyWith(
      displayLarge: applyTo(displayLarge),
      displayMedium: applyTo(displayMedium),
      displaySmall: applyTo(displaySmall),
      headlineLarge: applyTo(headlineLarge),
      headlineMedium: applyTo(headlineMedium),
      headlineSmall: applyTo(headlineSmall),
      titleLarge: applyTo(titleLarge),
      titleMedium: applyTo(titleMedium),
      titleSmall: applyTo(titleSmall),
      bodyLarge: applyTo(bodyLarge),
      bodyMedium: applyTo(bodyMedium),
      bodySmall: applyTo(bodySmall),
      labelLarge: applyTo(labelLarge),
      labelMedium: applyTo(labelMedium),
      labelSmall: applyTo(labelSmall),
    );
  }
}
