import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class CallWebView extends StatelessWidget {
  const CallWebView({
    super.key,
    required this.meetingLink,
    required this.title,
    this.onClose,
    this.onMinimize,
    this.showHeader = true,
  });

  final String meetingLink;
  final String title;
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userDisplayName = context.read<ProfileCubit>().state.user?.fullName ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose ?? () {},
                  icon: const Icon(Icons.close_rounded),
                  tooltip: context.t.general.close,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: InAppWebView(
            key: ValueKey<String>(meetingLink),
            initialUrlRequest: URLRequest(
              url: WebUri.uri(
                Uri.parse('$meetingLink&config.disableDeepLinking=true&userInfo.displayName="$userDisplayName"'),
              ),
            ),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              iframeAllow: "camera; microphone",
              allowsInlineMediaPlayback: true,
            ),
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
          ),
        ),
      ],
    );
  }
}
