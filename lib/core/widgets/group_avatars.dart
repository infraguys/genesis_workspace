import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';

class GroupAvatars extends StatelessWidget {
  final Color bgColor;
  const GroupAvatars({super.key, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageColors = theme.extension<MessageColors>();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 28,
        maxWidth: 128,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(7, (index) {
          final double leftOffset = (15 * index).toDouble();
          return Positioned(
            left: leftOffset,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: bgColor,
                  width: 1,
                ),
              ),
              child: UserAvatar(
                size: 28,
              ),
            ),
          );
        }).reversed.toList(),
      ),
    );
  }
}
