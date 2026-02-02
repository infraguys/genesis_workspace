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
    return isSelected
        ? Assets.icons.circleSelectedGreen.svg()
        : Icon(
            Icons.circle_outlined,
            size: 20,
          );
  }
}
