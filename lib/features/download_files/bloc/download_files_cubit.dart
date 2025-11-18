import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/download_files/entities/download_file_entity.dart';
import 'package:genesis_workspace/services/download_files/download_files_service.dart';
import 'package:injectable/injectable.dart';

part 'download_files_state.dart';

@injectable
class DownloadFilesCubit extends Cubit<DownloadFilesState> {
  DownloadFilesCubit(this._downloadFilesService)
    : super(
        DownloadFilesState(
          files: [],
          isFinished: true,
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
      emit(state.copyWith(isFinished: true));
      inspect(response);
    } catch (e) {
      inspect(e);
    }
  }
}
