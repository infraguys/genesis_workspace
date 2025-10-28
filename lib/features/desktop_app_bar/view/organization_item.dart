import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class OrganizationItem extends StatelessWidget {
  final int unreadCount;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  OrganizationItem({
    super.key,
    required this.unreadCount,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final GlobalKey<CustomPopupState> actionsPopupKey = GlobalKey<CustomPopupState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPopup(
      key: actionsPopupKey,
      isLongPress: currentSize(context) < ScreenSize.lTablet,
      backgroundColor: theme.colorScheme.surface,
      arrowColor: theme.colorScheme.surface,
      content: SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            TextButton(
              onPressed: () {
                context.pop(context);
                onDelete();
              },
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: Text(context.t.organizations.deleteOrganization),
            ),
          ],
        ),
      ),
      child: Badge(
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
              onSecondaryTap: () {
                actionsPopupKey.currentState?.show();
              },
            ),
          ),
        ),
      ),
    );
  }
}
