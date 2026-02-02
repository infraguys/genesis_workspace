import 'package:flutter/material.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  const SelectionIndicator({
    super.key,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: SizedBox(
        key: ValueKey<bool>(isSelected),
        width: 20,
        height: 20,
        child: Center(
          child: isSelected
              ? Assets.icons.circleSelectedGreen.svg(width: 20, height: 20)
              : const Icon(
                  Icons.circle_outlined,
                  size: 20,
                ),
        ),
      ),
    );
  }
}
