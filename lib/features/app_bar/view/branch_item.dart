import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BranchItem extends StatelessWidget {
  const BranchItem({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.icon,
    this.size = 64,
    this.borderRadius = 12,
  });

  final bool isSelected;
  final VoidCallback onPressed;
  final SvgPicture icon;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color baseOverlay = theme.colorScheme.onSurface;

    return Material(
      color: isSelected ? theme.colorScheme.onSurface.withOpacity(0.05) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(borderRadius),
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) {
            return baseOverlay.withOpacity(0.16);
          }
          if (states.contains(MaterialState.hovered)) {
            return baseOverlay.withOpacity(0.08);
          }
          if (states.contains(MaterialState.focused)) {
            return baseOverlay.withOpacity(0.12);
          }
          return null;
        }),
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: icon,
            // child: SvgPicture.asset(
            //   Assets.icons.calendarMonth.path,
            //   // Чуть ярче при выборе, иначе — приглушённо.
            //   color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            // ),
          ),
        ),
      ),
    );
  }
}
