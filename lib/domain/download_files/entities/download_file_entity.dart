import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class DownloadFileEntity extends Equatable {
  final String pathToFile;
  final String fileName;
  const DownloadFileEntity({required this.pathToFile, required this.fileName});

  @override
  // TODO: implement props
  List<Object?> get props => [pathToFile];
}

class DownloadingFileEntity extends DownloadFileEntity {
  const DownloadingFileEntity({
    required super.pathToFile,
    required this.progress,
    required this.total,
    required super.fileName,
  });
  final int progress;
  final int total;

  DownloadingFileEntity copyWith({int? progress, int? total}) {
    return DownloadingFileEntity(
      pathToFile: pathToFile,
      fileName: fileName,
      progress: progress ?? this.progress,
      total: total ?? this.total,
    );
  }
}

class DownloadedFileEntity extends DownloadFileEntity {
  const DownloadedFileEntity({
    required super.pathToFile,
    required this.bytes,
    required super.fileName,
  });
  final Uint8List bytes;
}
