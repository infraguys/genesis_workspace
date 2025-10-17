import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UpdateForceView extends StatefulWidget {
  final Uri appcastUrlMacOsAndWindows; // RSS для Sparkle/WinSparkle
  final Uri linuxDownloadUrl; // Страница с последней AppImage/инструкцией
  final String latestVersion; // Например, "1.4.0"

  const UpdateForceView({
    super.key,
    required this.appcastUrlMacOsAndWindows,
    required this.linuxDownloadUrl,
    required this.latestVersion,
  });

  @override
  State<UpdateForceView> createState() => _UpdateForceViewState();
}

class _UpdateForceViewState extends State<UpdateForceView> {
  String currentVersion = '0.0.0';
  bool isBusy = false;
  String? lastMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });

    if (Platform.isMacOS || Platform.isWindows) {
      // await AutoUpdater.setFeedURL(widget.appcastUrlMacOsAndWindows.toString());
      // Можно отключить фоновую периодическую проверку и управлять вручную
      // await AutoUpdater.setScheduledCheckInterval(0);
    }
  }

  Future<void> _startUpdate() async {
    setState(() {
      isBusy = true;
      lastMessage = null;
    });

    try {
      if (Platform.isMacOS || Platform.isWindows) {
        // Откроется нативный диалог Sparkle/WinSparkle
        // await AutoUpdater.checkForUpdates();
      } else if (Platform.isLinux) {
        await launchUrlString(
          widget.linuxDownloadUrl.toString(),
          mode: LaunchMode.externalApplication,
        );
      } else {
        lastMessage = context.t.updateForce.unsupportedPlatform;
      }
    } catch (error) {
      lastMessage = context.t.updateForce.failedToStart(error: '$error');
    } finally {
      if (mounted) {
        setState(() => isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.update, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(context.t.updateForce.title, style: theme.textTheme.headlineSmall),
                Text(
                  context.t.updateForce.description(
                    current: currentVersion,
                    latest: widget.latestVersion,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isBusy ? null : _startUpdate,
                    child: Text(
                      isBusy
                          ? context.t.updateForce.loading
                          : context.t.updateForce.update,
                    ),
                  ),
                ),
                if (lastMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(lastMessage!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
