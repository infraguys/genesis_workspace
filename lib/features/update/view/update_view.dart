import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/flavor.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UpdateView extends StatefulWidget {
  const UpdateView({super.key});

  @override
  State<UpdateView> createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  String appVersion = '';
  String downloadSize = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _desktopUpdaterController.removeListener(updaterListener);
    // _desktopUpdaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UpdateCubit, UpdateState>(
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(title: 'Choose version'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _buildBody(context, theme, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, UpdateState state) {
    switch (state.operationStatus) {
      case UpdateOperationStatus.downloading:
      case UpdateOperationStatus.installing:
        return _buildProgress(context, theme, state);
      case UpdateOperationStatus.readyToRestart:
        return _buildRestartPrompt(context, theme, state);
      case UpdateOperationStatus.failure:
      case UpdateOperationStatus.idle:
        return _buildVersionList(context, theme, state);
    }
  }

  Widget _buildVersionList(BuildContext context, ThemeData theme, UpdateState state) {
    final versionsEntity = state.versionConfigEntity?.versions;
    final versionEntries = Flavor.isStage
        ? (versionsEntity?.dev ?? [])
        : (versionsEntity?.stable ?? []);

    if (state.status == UpdateStatus.loading && versionEntries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (versionEntries.isEmpty) {
      final message = state.errorMessage ?? context.t.general.nothingHereYet;
      return Center(
        child: Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      );
    }

    final showOperationError =
        state.operationStatus == UpdateOperationStatus.failure && state.updateError != null;
    final isBusy =
        state.operationStatus == UpdateOperationStatus.downloading ||
        state.operationStatus == UpdateOperationStatus.installing;

    return Column(
      children: [
        if (showOperationError) ...[
          _ErrorBanner(message: state.updateError!),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final version = versionEntries[index];
              final isSelected = state.selectedVersion?.version == version.version;
              final trailing = isSelected && isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : isSelected && state.operationStatus == UpdateOperationStatus.readyToRestart
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null;

              return ListTile(
                title: Text(version.version),
                subtitle: version.shortVersion != version.version
                    ? Text(version.shortVersion)
                    : null,
                trailing: trailing,
                enabled: !isBusy,
                onTap: isBusy ? null : () => context.read<UpdateCubit>().installVersion(version),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: versionEntries.length,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context, ThemeData theme, UpdateState state) {
    final isDownloading = state.operationStatus == UpdateOperationStatus.downloading;
    final versionLabel = state.selectedVersion?.version ?? '';
    final total = state.totalBytes;
    final downloaded = state.downloadedBytes;
    final progressValue = total > 0 ? downloaded / total : null;
    final progressText = total > 0
        ? '${formatFileSize(downloaded)} / ${formatFileSize(total)}'
        : formatFileSize(downloaded);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isDownloading ? 'Downloading update...' : 'Installing update...',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (versionLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(versionLabel, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            if (isDownloading) ...[
              LinearProgressIndicator(value: progressValue),
              const SizedBox(height: 12),
              Text(
                progressValue != null ? progressText : '$progressText downloaded',
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRestartPrompt(BuildContext context, ThemeData theme, UpdateState state) {
    final versionLabel = state.selectedVersion?.version ?? state.actualVersion;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Update installed',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (versionLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Version $versionLabel is ready to use.', textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<UpdateCubit>().restartApplication(),
              child: Text(context.t.updateWidget.restart),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
      ),
    );
  }
}
