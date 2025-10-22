import 'dart:developer';

import 'package:desktop_updater/desktop_updater.dart';
import 'package:desktop_updater/updater_controller.dart';
import 'package:desktop_updater/widget/update_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UpdateView extends StatefulWidget {
  const UpdateView({super.key});

  @override
  State<UpdateView> createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  late final DesktopUpdaterController _desktopUpdaterController;

  String appVersion = '';
  String downloadSize = '';

  updaterListener() {
    setState(() {
      appVersion = _desktopUpdaterController.appVersion ?? '';
      downloadSize = formatFileSize((_desktopUpdaterController.downloadSize! * 1024).floor());
    });
  }

  @override
  void initState() {
    super.initState();
    final appArchiveUrl = context.read<UpdateCubit>().state.appArchiveUrl;
    _desktopUpdaterController = DesktopUpdaterController(appArchiveUrl: Uri.parse(appArchiveUrl));
    _desktopUpdaterController.addListener(updaterListener);
  }

  @override
  void dispose() {
    _desktopUpdaterController.removeListener(updaterListener);
    _desktopUpdaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updateWidgetTexts = context.t.updateWidget;
    inspect(_desktopUpdaterController);
    _desktopUpdaterController.localization = DesktopUpdateLocalization(
      updateAvailableText: updateWidgetTexts.updateAvailable,
      newVersionAvailableText: updateWidgetTexts.newVersionAvailable(
        version: appVersion,
      ),
      newVersionLongText: updateWidgetTexts.newVersionLong(
        size: downloadSize,
      ),
      restartText: updateWidgetTexts.restart,
      warningTitleText: updateWidgetTexts.warningTitle,
      restartWarningText: updateWidgetTexts.restartWarning,
      warningCancelText: updateWidgetTexts.warningCancel,
      warningConfirmText: updateWidgetTexts.warningConfirm,
    );

    return BlocBuilder<UpdateCubit, UpdateState>(
      builder: (context, state) {
        final isLoading = state.status == UpdateStatus.loading;
        final hasError = state.status == UpdateStatus.failure;

        return Scaffold(
          body: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.update, size: 64, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(context.t.updateForce.title, style: theme.textTheme.headlineSmall),
                      if (hasError && state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (appVersion.isEmpty)
                Center(
                  child: CircularProgressIndicator(),
                ),
              DesktopUpdateDirectCard(
                controller: _desktopUpdaterController,
                child: SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
