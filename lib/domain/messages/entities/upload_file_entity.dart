import 'package:file_picker/file_picker.dart';
import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class UploadFileResponseEntity extends ResponseEntity {
  final String url;
  final String? uri;
  final String filename;

  UploadFileResponseEntity({
    required super.msg,
    required super.result,
    required this.url,
    this.uri,
    required this.filename,
  });

  UploadedFileEntity toUploadedFileEntity({required int size, required String localId}) =>
      UploadedFileEntity(filename: filename, url: url, uri: uri, size: size, localId: localId);
}

class UploadFileRequestEntity {
  final PlatformFile file;
  UploadFileRequestEntity({required this.file});

  UploadFileRequestDto toDto() => UploadFileRequestDto(file: file);
}

sealed class UploadFileEntity {
  final String localId; // уникальный id для локального трекинга
  final String filename;
  final int size;

  const UploadFileEntity({required this.localId, required this.filename, required this.size});
}

class UploadedFileEntity extends UploadFileEntity {
  final String url;
  final String? uri;

  const UploadedFileEntity({
    required super.localId,
    required super.filename,
    required super.size,
    required this.url,
    this.uri,
  });
}

class UploadingFileEntity extends UploadFileEntity {
  final int? bytesSent;
  final int? bytesTotal;

  const UploadingFileEntity({
    required super.localId,
    required super.filename,
    required super.size,
    this.bytesSent,
    this.bytesTotal,
  });

  double? get progress => (bytesSent != null && bytesTotal != null && bytesTotal! > 0)
      ? (bytesSent! / bytesTotal!).clamp(0.0, 1.0)
      : null;

  UploadingFileEntity copyWith({
    String? localId,
    String? filename,
    int? size,
    int? bytesSent,
    int? bytesTotal,
  }) {
    return UploadingFileEntity(
      localId: localId ?? this.localId,
      filename: filename ?? this.filename,
      size: size ?? this.size,
      bytesSent: bytesSent ?? this.bytesSent,
      bytesTotal: bytesTotal ?? this.bytesTotal,
    );
  }
}
