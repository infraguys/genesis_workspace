import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class DownloadFileEntity extends Equatable {
  final String pathToFile;
  const DownloadFileEntity({required this.pathToFile});

  @override
  // TODO: implement props
  List<Object?> get props => [pathToFile];
}

class DownloadingFileEntity extends DownloadFileEntity {
  const DownloadingFileEntity({required super.pathToFile, required this.progress, required this.total});
  final int progress;
  final int total;

  DownloadingFileEntity copyWith({int? progress, int? total}) {
    return DownloadingFileEntity(
      pathToFile: pathToFile,
      progress: progress ?? this.progress,
      total: total ?? this.total,
    );
  }
}

class DownloadedFileEntity extends DownloadFileEntity {
  const DownloadedFileEntity({required super.pathToFile, required this.bytes});
  final Uint8List bytes;
}
