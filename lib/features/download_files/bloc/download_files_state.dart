part of 'download_files_cubit.dart';

class DownloadFilesState {
  List<DownloadFileEntity> files;
  final bool isFinished;

  DownloadFilesState({required this.files, required this.isFinished});

  DownloadFilesState copyWith({List<DownloadFileEntity>? files, bool? isFinished}) {
    return DownloadFilesState(
      files: files ?? this.files,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
