import 'package:flutter/material.dart';

class OrganizationItem extends StatelessWidget {
  final int unreadCount;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  const OrganizationItem({
    super.key,
    required this.unreadCount,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Badge(
      isLabelVisible: unreadCount > 0,
      label: Text(unreadCount.toString()),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: NetworkImage(imagePath), fit: BoxFit.fill),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            mouseCursor: SystemMouseCursors.click,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              final Color primary = theme.colorScheme.primary;
              if (states.contains(WidgetState.pressed)) {
                return primary.withValues(alpha: 0.16);
              }
              if (states.contains(WidgetState.hovered)) {
                return primary.withValues(alpha: 0.08);
              }
              return null;
            }),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
