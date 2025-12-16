import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

enum _ReleaseChannel { dev, stable }

class UpdateView extends StatefulWidget {
  const UpdateView({super.key});

  @override
  State<UpdateView> createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  var _selectedChannel = _ReleaseChannel.dev;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UpdateCubit, UpdateState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.t.updateView.title)),
          backgroundColor: theme.colorScheme.surface,
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
    final devEntries = versionsEntity?.dev ?? <VersionEntryEntity>[];
    final stableEntries = versionsEntity?.stable ?? <VersionEntryEntity>[];
    final versionEntries = _selectedChannel == _ReleaseChannel.dev ? devEntries : stableEntries;

    if (state.status == UpdateStatus.loading && devEntries.isEmpty && stableEntries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final showOperationError = state.operationStatus == UpdateOperationStatus.failure && state.updateError != null;
    final isBusy =
        state.operationStatus == UpdateOperationStatus.downloading ||
        state.operationStatus == UpdateOperationStatus.installing;
    final selectedLatest = _selectedChannel == _ReleaseChannel.dev
        ? state.versionConfigEntity?.latest.dev
        : state.versionConfigEntity?.latest.stable;
    final latestVersionCandidates = <String>{};
    if (selectedLatest != null) {
      if (selectedLatest.version.isNotEmpty) {
        latestVersionCandidates.add(selectedLatest.version);
      }
      if (selectedLatest.shortVersion.isNotEmpty) {
        latestVersionCandidates.add(selectedLatest.shortVersion);
      }
    }
    if (latestVersionCandidates.isEmpty && state.actualVersion.isNotEmpty) {
      latestVersionCandidates.add(state.actualVersion);
    }

    final hasAnyEntries = devEntries.isNotEmpty || stableEntries.isNotEmpty;
    final listContent = !hasAnyEntries
        ? Center(
            child: Text(
              state.errorMessage ?? context.t.general.nothingHereYet,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        : versionEntries.isEmpty
        ? Center(
            child: Text(
              context.t.general.nothingHereYet,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        : ListView.separated(
            itemBuilder: (context, index) {
              final version = versionEntries[index];
              final isSelected = state.selectedVersion?.version == version.version;
              final isLatest =
                  latestVersionCandidates.contains(version.version) ||
                  latestVersionCandidates.contains(version.shortVersion);
              final subtitleChildren = <Widget>[];
              if (version.shortVersion != version.version) {
                subtitleChildren.add(
                  Text(
                    version.shortVersion,
                    style: theme.textTheme.bodySmall,
                  ),
                );
              }
              if (isLatest) {
                if (subtitleChildren.isNotEmpty) {
                  subtitleChildren.add(const SizedBox(height: 4));
                }
                subtitleChildren.add(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        context.t.updateView.latestHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        version.version,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isLatest ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      _LatestBadge(label: context.t.updateView.latestBadge),
                    ],
                  ],
                ),
                subtitle: subtitleChildren.isEmpty
                    ? null
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: subtitleChildren,
                      ),
                trailing: trailing,
                enabled: !isBusy,
                onTap: isBusy ? null : () => context.read<UpdateCubit>().installVersion(version),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: versionEntries.length,
          );

    return Column(
      children: [
        _ReleaseChannelToggle(
          selectedChannel: _selectedChannel,
          onChanged: (channel) => setState(() => _selectedChannel = channel),
          devLabel: context.t.updateView.devChannel,
          stableLabel: context.t.updateView.stableChannel,
        ),
        const SizedBox(height: 12),
        if (showOperationError) ...[
          _ErrorBanner(message: state.updateError!),
          const SizedBox(height: 12),
        ],
        Expanded(child: listContent),
      ],
    );
  }

  Widget _buildProgress(BuildContext context, ThemeData theme, UpdateState state) {
    final isDownloading = state.operationStatus == UpdateOperationStatus.downloading;
    final versionLabel = state.selectedVersion?.version ?? '';
    final total = state.totalBytes;
    final downloaded = state.downloadedBytes;
    final progressValue = total > 0 ? downloaded / total : null;
    final formattedDownloaded = formatFileSize(downloaded);
    final progressText = total > 0
        ? context.t.updateView.progressWithTotal(
            downloaded: formattedDownloaded,
            total: formatFileSize(total),
          )
        : context.t.updateView.downloadedBytes(size: formattedDownloaded);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isDownloading ? context.t.updateView.downloading : context.t.updateView.installing,
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
              Text(progressText, textAlign: TextAlign.center),
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
              context.t.updateView.installed,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (versionLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                context.t.updateView.installedMessage(version: versionLabel),
                textAlign: TextAlign.center,
              ),
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

class _ReleaseChannelToggle extends StatelessWidget {
  const _ReleaseChannelToggle({
    required this.selectedChannel,
    required this.onChanged,
    required this.devLabel,
    required this.stableLabel,
  });

  final _ReleaseChannel selectedChannel;
  final ValueChanged<_ReleaseChannel> onChanged;
  final String devLabel;
  final String stableLabel;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ReleaseChannel>(
      segments: [
        ButtonSegment(value: _ReleaseChannel.dev, label: Text(devLabel)),
        ButtonSegment(value: _ReleaseChannel.stable, label: Text(stableLabel)),
      ],
      selected: <_ReleaseChannel>{selectedChannel},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
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

class _LatestBadge extends StatelessWidget {
  const _LatestBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, size: 16, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
