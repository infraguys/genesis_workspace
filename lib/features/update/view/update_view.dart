// import 'package:desktop_updater/desktop_updater.dart';
// import 'package:desktop_updater/updater_controller.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        final hasError = state.status == UpdateStatus.failure;
        final versionsEntity = state.versionConfigEntity?.versions;
        final versionEntries = Flavor.isStage
            ? (versionsEntity?.dev ?? [])
            : (versionsEntity?.stable ?? []);

        return Scaffold(
          appBar: WorkspaceAppBar(title: 'Choose version'),
          body: Expanded(
            child: versionEntries.isEmpty
                ? Center(
                    child: state.status == UpdateStatus.loading
                        ? const CircularProgressIndicator()
                        : Text(
                            hasError
                                ? context.t.general.somethingWentWrong
                                : context.t.general.nothingHereYet,
                            style: theme.textTheme.bodyMedium,
                          ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    itemBuilder: (context, index) {
                      final version = versionEntries[index];
                      return ListTile(
                        title: Text(version.version),
                        subtitle: version.shortVersion != version.version
                            ? Text(version.shortVersion)
                            : null,
                        onTap: () {
                          inspect(version);
                          context.read<UpdateCubit>().getVersionBundle(version.linux.url);
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: versionEntries.length,
                  ),
          ),
        );
      },
    );
  }
}
