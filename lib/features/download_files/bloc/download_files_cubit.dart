import 'dart:developer';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/download_files/entities/download_file_entity.dart';
import 'package:genesis_workspace/services/download_files/download_files_service.dart';
import 'package:injectable/injectable.dart';
import 'package:open_file/open_file.dart';

part 'download_files_state.dart';

@injectable
class DownloadFilesCubit extends Cubit<DownloadFilesState> {
  DownloadFilesCubit(this._downloadFilesService)
    : super(
        DownloadFilesState(
          files: [],
          isFinished: true,
          duplicateRequestTick: 0,
        ),
      );

  final DownloadFilesService _downloadFilesService;

  Future<void> download(String pathToFile) async {
    try {
      String fileName = Uri.parse(pathToFile).pathSegments.last;
      DownloadingFileEntity downloadingFileEntity = DownloadingFileEntity(
        pathToFile: pathToFile,
        fileName: fileName,
        progress: 0,
        total: 1,
      );
      if (state.files.any((file) => file.pathToFile == pathToFile)) {
        emit(state.copyWith(duplicateRequestTick: state.duplicateRequestTick + 1));
        return;
      }

      emit(state.copyWith(isFinished: false));
      List<DownloadFileEntity> updatedFiles = [...state.files];
      final index = state.files.length;
      updatedFiles.add(downloadingFileEntity);
      emit(state.copyWith(files: updatedFiles));
      final response = await _downloadFilesService.download(
        pathToFile,
        onReceiveProgress: (progress, total) {
          downloadingFileEntity = downloadingFileEntity.copyWith(
            progress: progress,
            total: total,
          );
          updatedFiles[index] = downloadingFileEntity;
          emit(state.copyWith(files: updatedFiles));
        },
      );
      final bytes = response.data ?? Uint8List(0);
      final localPath =
          await _saveToFileSystem(
            fileName: fileName,
            bytes: bytes,
          ) ??
          '';
      updatedFiles[index] = DownloadedFileEntity(
        pathToFile: pathToFile,
        bytes: bytes,
        fileName: fileName,
        localFilePath: localPath,
      );
      emit(state.copyWith(isFinished: true, files: updatedFiles));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> openFile(String filePath) async {
    try {
      if (filePath.isEmpty) return;
      await OpenFile.open(filePath);
    } catch (e) {
      inspect(e);
    }
  }

  Future<String?> _saveToFileSystem({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final String extension = _extractExtension(fileName);
    final String sanitizedName = _sanitizeFileName(_extractFileNameWithoutExtension(fileName));

    try {
      return await FileSaver.instance.saveFile(
        name: sanitizedName,
        bytes: bytes,
        fileExtension: extension,
        mimeType: _resolveMimeType(extension),
      );
    } catch (error) {
      inspect(error);
      return null;
    }
  }

  String _extractExtension(String fileName) {
    final int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _extractFileNameWithoutExtension(String fileName) {
    final int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName.isEmpty ? 'downloaded_file' : fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  String _sanitizeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();
    if (sanitized.isEmpty) {
      return 'downloaded_file';
    }
    return sanitized;
  }

  MimeType _resolveMimeType(String extension) {
    if (extension.isEmpty) return MimeType.other;
    return _extensionMimeTypes[extension.toLowerCase()] ?? MimeType.other;
  }
}

const Map<String, MimeType> _extensionMimeTypes = <String, MimeType>{
  'aac': MimeType.aac,
  'apng': MimeType.apng,
  'asice': MimeType.asice,
  'asics': MimeType.asics,
  'avi': MimeType.avi,
  'avif': MimeType.avif,
  'bmp': MimeType.bmp,
  'csv': MimeType.csv,
  'epub': MimeType.epub,
  'gif': MimeType.gif,
  'heic': MimeType.heic,
  'heif': MimeType.heif,
  'jpg': MimeType.jpeg,
  'jpeg': MimeType.jpeg,
  'json': MimeType.json,
  'md': MimeType.markdown,
  'mp3': MimeType.mp3,
  'mp4': MimeType.mp4Video,
  'mpeg': MimeType.mpeg,
  'odp': MimeType.openDocPresentation,
  'ods': MimeType.openDocSheets,
  'odt': MimeType.openDocText,
  'otf': MimeType.otf,
  'pdf': MimeType.pdf,
  'png': MimeType.png,
  'ppt': MimeType.microsoftPresentation,
  'pptx': MimeType.microsoftPresentation,
  'rar': MimeType.rar,
  'sql': MimeType.sql,
  'svg': MimeType.svg,
  'txt': MimeType.text,
  'ttf': MimeType.ttf,
  'webm': MimeType.webm,
  'webp': MimeType.webp,
  'xml': MimeType.xml,
  'yaml': MimeType.yaml,
  'yml': MimeType.yaml,
  'zip': MimeType.zip,
  'xls': MimeType.microsoftExcel,
  'xlsx': MimeType.microsoftExcel,
  'doc': MimeType.microsoftWord,
  'docx': MimeType.microsoftWord,
};
