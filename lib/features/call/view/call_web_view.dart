import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(meetingLink))),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              iframeAllow: "camera; microphone",
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
