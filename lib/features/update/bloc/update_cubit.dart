import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
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
      final currentShortVersion = packageInfo.buildNumber.isNotEmpty
          ? packageInfo.buildNumber
          : packageInfo.version;

      final response = await _getVersionConfigUseCase.call();
      inspect(response);
      final releaseChannel = Flavor.isStage ? response.latest.dev : response.latest.stable;
      final minSupportedShortVersion = Flavor.isStage
          ? response.policy.update.minVersion.minShortDev
          : response.policy.update.minVersion.minShortStable;

      final latestShortVersion = releaseChannel.shortVersion;

      final isNewUpdateAvailable = _compareVersions(currentShortVersion, latestShortVersion) < 0;
      final isUpdateRequired = _compareVersions(currentShortVersion, minSupportedShortVersion) < 0;

      final actualVersionString = releaseChannel.version;
      final linuxUpdateUrl = releaseChannel.linux.url;
      print(linuxUpdateUrl);

      final archiveJson = _buildAppArchiveJson(
        packageInfo: packageInfo,
        config: response,
        isUpdateRequired: isUpdateRequired,
        targetChannel: releaseChannel,
      );

      emit(
        state.copyWith(
          status: UpdateStatus.success,
          // isNewUpdateAvailable: isNewUpdateAvailable,
          // isUpdateRequired: isUpdateRequired,
          currentVersion: currentVersion,
          actualVersion: actualVersionString,
          linuxUpdateUrl: linuxUpdateUrl,
          appArchiveJson: archiveJson,
        ),
      );
    } catch (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);

      emit(state.copyWith(status: UpdateStatus.failure, errorMessage: error.toString()));
    }
  }

  int _compareVersions(String left, String right) {
    final leftSegments = _parseVersionSegments(left);
    final rightSegments = _parseVersionSegments(right);

    final maxLength = leftSegments.length > rightSegments.length
        ? leftSegments.length
        : rightSegments.length;

    for (var index = 0; index < maxLength; index++) {
      final leftValue = index < leftSegments.length ? leftSegments[index] : 0;
      final rightValue = index < rightSegments.length ? rightSegments[index] : 0;

      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }

    return 0;
  }

  List<int> _parseVersionSegments(String version) {
    return version
        .split('.')
        .map((segment) => int.tryParse(RegExp(r'\d+').firstMatch(segment)?.group(0) ?? '') ?? 0)
        .toList(growable: false);
  }

  String _buildAppArchiveJson({
    required PackageInfo packageInfo,
    required VersionConfigEntity config,
    required bool isUpdateRequired,
    required ReleaseChannelEntity targetChannel,
  }) {
    final minShortVersionString = Flavor.isStage
        ? config.policy.update.minVersion.minShortDev
        : config.policy.update.minVersion.minShortStable;
    final mandatoryThreshold = _normalizeShortVersion(minShortVersionString);

    final versionEntries = Flavor.isStage ? config.versions.dev : config.versions.stable;

    final items = versionEntries
        .map(
          (entry) => {
            'version': entry.version,
            'shortVersion': _normalizeShortVersion(entry.shortVersion),
            'changes': [
              {'type': 'info', 'message': 'Update notes are not available for ${entry.version}'},
            ],
            'date': DateTime.now().toIso8601String().split('T').first,
            'mandatory': _normalizeShortVersion(entry.shortVersion) <= mandatoryThreshold,
            'url': entry.linux.url,
            'platform': 'linux',
          },
        )
        .toList();

    if (items.isEmpty) {
      items.add({
        'version': targetChannel.version,
        'shortVersion': _normalizeShortVersion(targetChannel.shortVersion),
        'changes': [
          {
            'type': 'info',
            'message': 'Update notes are not available for ${targetChannel.version}',
          },
        ],
        'date': DateTime.now().toIso8601String().split('T').first,
        'mandatory': isUpdateRequired,
        'url': targetChannel.linux.url,
        'platform': 'linux',
      });
    }

    final appArchive = {
      'appName': packageInfo.appName,
      'description': 'Generated update manifest for ${packageInfo.appName}',
      'items': items,
    };

    return jsonEncode(appArchive);
  }

  int _normalizeShortVersion(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return 0;
    }
    return int.tryParse(digitsOnly) ?? 0;
  }
}

void disposeUpdateCubit(UpdateCubit cubit) => cubit.close();
