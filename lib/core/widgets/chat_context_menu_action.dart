import 'package:flutter/material.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class ChatContextMenuAction extends StatelessWidget {
  const ChatContextMenuAction({
    super.key,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final Color textColor;
  final SvgGenImage icon;
  final ColorFilter iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    const iconSize = 20.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36.0),
      child: Material(
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: .circular(8),
          onTap: onTap,
          child: Padding(
            padding: const .symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              spacing: 12.0,
              children: [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: icon.svg(
                    width: iconSize,
                    height: iconSize,
                    colorFilter: iconColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: .w500, color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}