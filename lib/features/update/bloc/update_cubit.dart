import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
import 'package:genesis_workspace/domain/common/usecases/get_version_config_use_case.dart';
import 'package:genesis_workspace/flavor.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tar/tar.dart';

part 'update_state.dart';

@LazySingleton(dispose: disposeUpdateCubit)
class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit(this._getVersionConfigUseCase)
    : super(
        const UpdateState(
          status: UpdateStatus.initial,
          isUpdateRequired: false,
          isNewUpdateAvailable: false,
          currentVersion: '',
          actualVersion: '',
          errorMessage: null,
          versionConfigEntity: null,
        ),
      );

  final GetVersionConfigUseCase _getVersionConfigUseCase;
  final Dio _dio = Dio();

  Future<void> checkUpdateNeed() async {
    emit(state.copyWith(status: UpdateStatus.loading, errorMessage: null));

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _getVersionConfigUseCase.call();

      inspect(response);

      final releaseChannel = Flavor.isStage ? response.latest.dev : response.latest.stable;
      final minSupportedShortVersion = Flavor.isStage
          ? response.policy.update.minVersion.minShortDev
          : response.policy.update.minVersion.minShortStable;

      final latestShortVersion = releaseChannel.shortVersion;
      final isNewUpdateAvailable = compareVersions(currentVersion, latestShortVersion) < 0;
      final isUpdateRequired = compareVersions(currentVersion, minSupportedShortVersion) < 0;

      final actualVersionString = releaseChannel.version;

      emit(
        state.copyWith(
          versionConfigEntity: response,
          status: UpdateStatus.success,
          isNewUpdateAvailable: isNewUpdateAvailable,
          isUpdateRequired: isUpdateRequired,
          currentVersion: currentVersion,
          actualVersion: actualVersionString,
        ),
      );
    } catch (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);

      emit(state.copyWith(status: UpdateStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> getVersionBundle(String url) async {
    try {
      final dio = Dio();

      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (downloaded, total) {
          print('$downloaded / $total');
        },
      );

      final bytes = Uint8List.fromList(response.data!);

      // 1️⃣ Создаём временный файл
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/bundle.tar.gz';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('Файл сохранён: $filePath');

      // 2️⃣ Распаковываем .tar.gz
      final inputStream = file.openRead();

      // Сначала нужно распаковать GZip, потом читать Tar
      final decompressed = inputStream.transform(gzip.decoder);
      final reader = TarReader(decompressed);

      while (await reader.moveNext()) {
        final entry = reader.current;
        print('Файл: ${entry.header.name}');
        final content = await entry.contents.transform(utf8.decoder).toList();

        // Пример: вывести первые 100 символов содержимого
        // print(content.join().substring(0, 100));
        inspect(content);
      }
    } catch (e, s) {
      print('Ошибка при загрузке или разархивировании: $e');
      print(s);
    }
  }
}

void disposeUpdateCubit(UpdateCubit cubit) => cubit.close();
