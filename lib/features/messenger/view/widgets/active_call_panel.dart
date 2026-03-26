import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ActiveCallPanel extends StatelessWidget {
  const ActiveCallPanel({
    super.key,
    required this.callState,
    required this.titleText,
    required this.activeCallKey,
    required this.onRestoreCall,
    required this.onReportDockRect,
    required this.onClearDockRect,
  });

  final CallState callState;
  final String titleText;
  final GlobalKey activeCallKey;
  final VoidCallback onRestoreCall;
  final VoidCallback onReportDockRect;
  final VoidCallback onClearDockRect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (callState.isCallActive) {
        onReportDockRect();
      } else {
        onClearDockRect();
      }
    });

    if (!callState.isCallActive) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: activeCallKey,
        padding:
            EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ).copyWith(
              top: 20,
            ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              titleText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.green,
                fontSize: 14,
              ),
            ),
            IconButton(
              tooltip: context.t.call.resumeCall,
              onPressed: onRestoreCall,
              icon: Assets.icons.joinCall.svg(),
            ),
          ],
        ),
      ),
    );
  }
}
