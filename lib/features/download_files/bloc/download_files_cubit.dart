import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/services/download_files/download_files_service.dart';
import 'package:injectable/injectable.dart';

part 'download_files_state.dart';

@injectable
class DownloadFilesCubit extends Cubit<DownloadFilesState> {
  DownloadFilesCubit(this._downloadFilesService) : super(DownloadFilesState());

  final DownloadFilesService _downloadFilesService;

  Future<void> download(String pathToFile) async {
    try {
      final response = await _downloadFilesService.download(pathToFile);
      inspect(response);
    } catch (e) {
      inspect(e);
    }
  }
}
