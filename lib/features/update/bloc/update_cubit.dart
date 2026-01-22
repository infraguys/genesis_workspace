import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
import 'package:genesis_workspace/domain/common/usecases/get_version_config_sha_use_case.dart';
import 'package:genesis_workspace/domain/common/usecases/get_version_config_use_case.dart';
import 'package:genesis_workspace/flavor.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:tar/tar.dart';

part 'update_state.dart';

@LazySingleton(dispose: disposeUpdateCubit)
class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit(
    this._getVersionConfigUseCase,
    this._getVersionConfigShaUseCase,
  ) : super(
        const UpdateState(
          status: UpdateStatus.initial,
          isUpdateRequired: false,
          isNewUpdateAvailable: false,
          currentVersion: '',
          actualVersion: '',
          errorMessage: null,
          versionConfigEntity: null,
          operationStatus: UpdateOperationStatus.idle,
          downloadedBytes: 0,
          totalBytes: 0,
          selectedVersion: null,
          updateError: null,
          isUpdateSecured: false,
        ),
      );

  final GetVersionConfigUseCase _getVersionConfigUseCase;
  final GetVersionConfigShaUseCase _getVersionConfigShaUseCase;
  final Dio _dio = Dio();
  File? _windowsUpdateScript;

  Future<void> checkUpdateNeed() async {
    emit(
      state.copyWith(
        status: UpdateStatus.loading,
        errorMessage: null,
        updateError: null,
        operationStatus: UpdateOperationStatus.idle,
        selectedVersion: null,
      ),
    );

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final shaResponse = await _getVersionConfigShaUseCase.call();
      final response = await _getVersionConfigUseCase.call();

      final String sha256 = response.sha256.trim().split(RegExp(r'\s+')).first;
      final String shaResponseTrimmed = shaResponse.trim().split(RegExp(r'\s+')).first;

      final bool isSecured = shaResponseTrimmed == sha256;

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
          isUpdateSecured: isSecured,
        ),
      );
    } catch (error, stackTrace) {
      log('Failed to check update need', error: error, stackTrace: stackTrace);

      emit(state.copyWith(status: UpdateStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> installVersion(VersionEntryEntity version) async {
    if (!state.isUpdateSecured) {
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: 'Could not install unsecured update.',
        ),
      );
      return;
    }
    if (state.operationStatus == UpdateOperationStatus.downloading ||
        state.operationStatus == UpdateOperationStatus.installing) {
      return;
    }

    if (!Platform.isLinux && !Platform.isWindows) {
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: 'Updates are only supported on Linux/Windows at the moment.',
          selectedVersion: version,
        ),
      );
      return;
    }

    if (Platform.isLinux) {
      await _installLinux(version);
    } else if (Platform.isWindows) {
      await _installWindows(version);
    }
  }

  Future<void> restartApplication() async {
    if (state.operationStatus != UpdateOperationStatus.readyToRestart) {
      return;
    }

    try {
      if (Platform.isWindows && _windowsUpdateScript != null) {
        final script = _windowsUpdateScript!;
        _windowsUpdateScript = null;
        await Process.start(
          'cmd',
          ['/c', script.path],
          workingDirectory: _resolveInstallDirectory().path,
          mode: ProcessStartMode.detached,
        );
        exit(0);
      }

      final executable = Platform.resolvedExecutable;
      final arguments = Platform.executableArguments;
      final workingDirectory = Directory.current.path;

      await Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        mode: ProcessStartMode.detached,
      );
      exit(0);
    } catch (error, stackTrace) {
      log('Failed to restart application', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: 'Failed to restart: $error',
        ),
      );
    }
  }

  Future<void> _installLinux(VersionEntryEntity version) async {
    final url = version.linux.url;
    if (url.isEmpty) {
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: 'Download URL is missing for the selected version.',
          selectedVersion: version,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        operationStatus: UpdateOperationStatus.downloading,
        downloadedBytes: 0,
        totalBytes: 0,
        updateError: null,
        selectedVersion: version,
      ),
    );

    final tempDir = await Directory.systemTemp.createTemp('genesis_update_');
    final archiveFile = File(p.join(tempDir.path, 'bundle.tar.gz'));
    final extractDir = Directory(p.join(tempDir.path, 'bundle'));

    try {
      await _downloadBundle(url, archiveFile);

      emit(state.copyWith(operationStatus: UpdateOperationStatus.installing));

      await extractDir.create(recursive: true);
      await _extractArchive(archiveFile, extractDir);

      final bundleRoot = await _detectBundleRoot(extractDir);
      final installDir = _resolveInstallDirectory();

      await _applyBundle(bundleRoot, installDir);

      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.readyToRestart,
          downloadedBytes: state.totalBytes == 0 ? state.downloadedBytes : state.totalBytes,
        ),
      );
    } catch (error, stackTrace) {
      log('Failed to install update', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: error.toString(),
        ),
      );
    } finally {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (error, stackTrace) {
        log('Failed to clean temporary update directory', error: error, stackTrace: stackTrace);
      }
    }
  }

  Future<void> _installWindows(VersionEntryEntity version) async {
    final url = version.win?.url ?? '';
    if (url.isEmpty) {
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: 'Download URL is missing for the selected version.',
          selectedVersion: version,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        operationStatus: UpdateOperationStatus.downloading,
        downloadedBytes: 0,
        totalBytes: 0,
        updateError: null,
        selectedVersion: version,
      ),
    );

    final tempDir = await Directory.systemTemp.createTemp('genesis_update_');
    final archiveFile = File(p.join(tempDir.path, 'bundle.tar.gz'));
    final extractDir = Directory(p.join(tempDir.path, 'bundle'));

    try {
      await _downloadBundle(url, archiveFile);

      emit(state.copyWith(operationStatus: UpdateOperationStatus.installing));

      await extractDir.create(recursive: true);
      await _extractArchive(archiveFile, extractDir);

      final bundleRoot = await _detectBundleRoot(extractDir);
      final installDir = _resolveInstallDirectory();
      final stagingDir = Directory(p.join(installDir.path, '_update_staging'));

      if (await stagingDir.exists()) {
        await stagingDir.delete(recursive: true);
      }
      await stagingDir.create(recursive: true);
      await _applyBundle(bundleRoot, stagingDir);

      _windowsUpdateScript = await _createWindowsUpdateScript(stagingDir, installDir);

      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.readyToRestart,
          downloadedBytes: state.totalBytes == 0 ? state.downloadedBytes : state.totalBytes,
        ),
      );
    } catch (error, stackTrace) {
      log('Failed to install update', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          operationStatus: UpdateOperationStatus.failure,
          updateError: error.toString(),
        ),
      );
    } finally {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (error, stackTrace) {
        log('Failed to clean temporary update directory', error: error, stackTrace: stackTrace);
      }
    }
  }

  Future<File> _createWindowsUpdateScript(
    Directory stagingDir,
    Directory installDir,
  ) async {
    final exeName = p.basename(Platform.resolvedExecutable);
    final scriptName = '_genesis_update_${DateTime.now().millisecondsSinceEpoch}.bat';
    final scriptFile = File(p.join(installDir.path, scriptName));
    final scriptContent = [
      '@echo off',
      'setlocal',
      'set "PID=$pid"',
      'set "SRC=${p.normalize(stagingDir.path)}"',
      'set "DST=${p.normalize(installDir.path)}"',
      'set "EXE=$exeName"',
      ':wait',
      'tasklist /FI "PID eq %PID%" | find "%PID%" >nul',
      'if not errorlevel 1 (',
      '  timeout /T 1 /NOBREAK >nul',
      '  goto wait',
      ')',
      'xcopy "%SRC%\\*" "%DST%\\" /E /H /C /I /Y >nul',
      'start "" "%DST%\\%EXE%"',
      'rmdir /S /Q "%SRC%"',
      'del "%~f0"',
      '',
    ].join('\r\n');

    await scriptFile.writeAsString(scriptContent, flush: true);
    return scriptFile;
  }

  Future<void> _downloadBundle(String url, File destination) async {
    await destination.parent.create(recursive: true);
    await destination.create(recursive: true);

    await _dio.download(
      url,
      destination.path,
      options: Options(responseType: ResponseType.stream),
      onReceiveProgress: (received, total) {
        final normalizedTotal = total < 0 ? 0 : total;
        emit(state.copyWith(downloadedBytes: received, totalBytes: normalizedTotal));
      },
    );
  }

  Future<void> _extractArchive(File archive, Directory outputDir) async {
    final reader = TarReader(archive.openRead().transform(gzip.decoder));
    try {
      while (await reader.moveNext()) {
        final entry = reader.current;
        final targetPath = _buildExtractPath(outputDir.path, entry.header.name);
        if (targetPath == null) {
          await entry.contents.drain<void>();
          continue;
        }

        switch (entry.header.typeFlag) {
          case TypeFlag.dir:
            final directory = Directory(targetPath);
            await directory.create(recursive: true);
            await _applyPermissions(directory, entry.header.mode);
            break;
          case TypeFlag.reg:
          case TypeFlag.regA:
            final file = File(targetPath);
            await file.parent.create(recursive: true);
            final sink = file.openWrite();
            await entry.contents.pipe(sink);
            await sink.close();
            await _applyPermissions(file, entry.header.mode);
            break;
          case TypeFlag.symlink:
            final linkName = entry.header.linkName;
            if (linkName != null && linkName.isNotEmpty) {
              final link = Link(targetPath);
              await Directory(p.dirname(targetPath)).create(recursive: true);
              if (await link.exists()) {
                await link.delete();
              }
              await link.create(linkName);
            } else {
              await entry.contents.drain<void>();
            }
            break;
          default:
            await entry.contents.drain<void>();
            break;
        }
      }
    } finally {
      await reader.cancel();
    }
  }

  Future<Directory> _detectBundleRoot(Directory extractionRoot) async {
    final binaryName = p.basename(Platform.resolvedExecutable);
    final queue = Queue<Directory>()..add(extractionRoot);
    Directory? fallback;

    while (queue.isNotEmpty) {
      final directory = queue.removeFirst();
      fallback ??= directory;

      final entities = await directory.list(followLinks: false).toList();
      final containsBinary = entities.any(
        (entity) => entity is File && p.basename(entity.path) == binaryName,
      );
      final containsDataDirectory = entities.any(
        (entity) => entity is Directory && p.basename(entity.path) == 'data',
      );

      if (containsBinary && containsDataDirectory) {
        return directory;
      }

      for (final entity in entities) {
        if (entity is Directory) {
          queue.add(entity);
        }
      }
    }

    return fallback ?? extractionRoot;
  }

  Directory _resolveInstallDirectory() {
    final executableFile = File(Platform.resolvedExecutable);
    return executableFile.parent;
  }

  Future<void> _applyBundle(Directory source, Directory destination) async {
    if (p.equals(p.normalize(source.path), p.normalize(destination.path))) {
      log('Bundle source and destination are identical, skipping copy.');
      return;
    }

    await for (final entity in source.list(followLinks: false)) {
      final entityName = p.basename(entity.path);
      final destinationPath = p.join(destination.path, entityName);

      if (entity is Directory) {
        final destDirectory = Directory(destinationPath);
        await destDirectory.create(recursive: true);
        final stat = await entity.stat();
        await _applyPermissions(destDirectory, stat.mode);
        await _applyBundle(entity, destDirectory);
      } else if (entity is File) {
        final destFile = File(destinationPath);
        await destFile.parent.create(recursive: true);
        if (await destFile.exists()) {
          await destFile.delete();
        }
        final stat = await entity.stat();
        try {
          await entity.copy(destinationPath);
        } on FileSystemException {
          final bytes = await entity.readAsBytes();
          await destFile.writeAsBytes(bytes, flush: true);
        }
        await _applyPermissions(destFile, stat.mode);
      } else if (entity is Link) {
        final target = await entity.target();
        final destLink = Link(destinationPath);
        await Directory(p.dirname(destinationPath)).create(recursive: true);
        if (await destLink.exists()) {
          await destLink.delete();
        }
        await destLink.create(target);
      }
    }
  }

  String? _buildExtractPath(String root, String entryName) {
    final sanitized = p.normalize(p.join(root, entryName));
    if (!p.isWithin(root, sanitized) && sanitized != root) {
      return null;
    }
    return sanitized;
  }

  Future<void> _applyPermissions(FileSystemEntity entity, int? mode) async {
    if (!Platform.isLinux || mode == null) {
      return;
    }

    final permissions = (mode & 0xFFF).toRadixString(8).padLeft(4, '0');

    try {
      await Process.run('chmod', [permissions, entity.path]);
    } catch (error, stackTrace) {
      log(
        'Failed to apply permissions $permissions to ${entity.path}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

void disposeUpdateCubit(UpdateCubit cubit) => cubit.close();
