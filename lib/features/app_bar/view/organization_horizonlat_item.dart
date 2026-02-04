import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class OrganizationHorizonlatItem extends StatelessWidget {
  final String name;
  final int unreadCount;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  OrganizationHorizonlatItem({
    super.key,
    required this.name,
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
      rootNavigator: true,
      content: SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            TextButton(
              onPressed: onDelete,
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: Text(context.t.organizations.deleteOrganization),
            ),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
            borderRadius: BorderRadius.circular(8),
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
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount.toString()),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: NetworkImage(imagePath), fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
