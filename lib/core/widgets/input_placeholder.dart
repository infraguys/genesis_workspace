import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class InputPlaceholder extends StatelessWidget {
  const InputPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return SizedBox(
      height: 60.0,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // todo: вынести в Colors.scheme
          border: BoxBorder.fromLTRB(top: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: .1)))
        ),
        child:  Center(
          child:  Text(context.t.inputPlaceholder, style: textTheme.bodySmall!.copyWith(
            fontSize: 16
          ),),
        ),
      ),
    );
  }
}
