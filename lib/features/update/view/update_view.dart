import 'dart:developer';

import 'package:desktop_updater/updater_controller.dart';
import 'package:desktop_updater/widget/update_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UpdateView extends StatefulWidget {
  const UpdateView({super.key});

  @override
  State<UpdateView> createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  late final DesktopUpdaterController _desktopUpdaterController;

  @override
  void initState() {
    super.initState();
    _desktopUpdaterController = DesktopUpdaterController(
      appArchiveUrl: Uri.parse(
        'http://repository.genesis-core.tech:8081/genesis_workspace/app-archive.json',
      ),
    );
  }

  @override
  void dispose() {
    _desktopUpdaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UpdateCubit, UpdateState>(
      builder: (context, state) {
        final isLoading = state.status == UpdateStatus.loading;
        final hasError = state.status == UpdateStatus.failure;

        return Scaffold(
          body: DesktopUpdateWidget(
            controller: _desktopUpdaterController,
            child: Center(
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
                          current: state.currentVersion,
                          latest: state.actualVersion,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            try {
                              await _desktopUpdaterController.downloadUpdate();
                            } catch (e) {
                              inspect(e);
                            }
                          },
                          child: Text(
                            isLoading
                                ? context.t.updateForce.loading
                                : context.t.updateForce.update,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
