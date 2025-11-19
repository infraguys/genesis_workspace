part of 'download_files_cubit.dart';

class DownloadFilesState {
  List<DownloadFileEntity> files;
  final bool isFinished;
  final int duplicateRequestTick;

  DownloadFilesState({
    required this.files,
    required this.isFinished,
    required this.duplicateRequestTick,
  });

  DownloadFilesState copyWith({
    List<DownloadFileEntity>? files,
    bool? isFinished,
    int? duplicateRequestTick,
  }) {
    return DownloadFilesState(
      files: files ?? this.files,
      isFinished: isFinished ?? this.isFinished,
      duplicateRequestTick: duplicateRequestTick ?? this.duplicateRequestTick,
    );
  }
}
