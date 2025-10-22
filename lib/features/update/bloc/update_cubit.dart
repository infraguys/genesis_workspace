import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/common/usecases/get_version_config_use_case.dart';
import 'package:genesis_workspace/flavor.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'update_state.dart';

@LazySingleton(dispose: disposeUpdateCubit)
class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit(this._getVersionConfigUseCase) : super(const UpdateState());

  final GetVersionConfigUseCase _getVersionConfigUseCase;

  Future<void> checkUpdateNeed() async {
    emit(state.copyWith(status: UpdateStatus.loading, errorMessage: null));

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _getVersionConfigUseCase.call();
      final releaseChannel = Flavor.isStage ? response.latest.dev : response.latest.stable;
      final minSupportedShortVersion = Flavor.isStage
          ? response.policy.update.minVersion.minShortDev
          : response.policy.update.minVersion.minShortStable;

      final latestShortVersion = releaseChannel.shortVersion;
      final isNewUpdateAvailable = compareVersions(currentVersion, latestShortVersion) < 0;
      final isUpdateRequired = compareVersions(currentVersion, minSupportedShortVersion) < 0;

      final actualVersionString = releaseChannel.version;
      final linuxUpdateUrl = releaseChannel.linux.url;

      emit(
        state.copyWith(
          status: UpdateStatus.success,
          isNewUpdateAvailable: isNewUpdateAvailable,
          // isUpdateRequired: isUpdateRequired,
          currentVersion: currentVersion,
          actualVersion: actualVersionString,
          linuxUpdateUrl: linuxUpdateUrl,
        ),
      );
    } catch (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);

      emit(state.copyWith(status: UpdateStatus.failure, errorMessage: error.toString()));
    }
  }
}

void disposeUpdateCubit(UpdateCubit cubit) => cubit.close();
