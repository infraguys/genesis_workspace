import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class ResolveTopicIndicator extends StatelessWidget {
  const ResolveTopicIndicator({
    super.key,
    required this.isResolved,
  });

  final bool isResolved;

  @override
  Widget build(BuildContext context) {
    return switch (isResolved) {
      true => Assets.icons.check.svg(colorFilter: .mode(AppColors.green, .srcIn)),
      _ => SizedBox.square(dimension: 18),
    };
  }
}
