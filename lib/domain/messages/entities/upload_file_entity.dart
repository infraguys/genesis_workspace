import 'dart:typed_data';

import 'package:equatable/equatable.dart';
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

  UploadedFileEntity toUploadedFileEntity({
    required int size,
    required String localId,
    required UploadFileType type,
    required String path,
    required Uint8List bytes,
  }) => UploadedFileEntity(
    filename: filename,
    url: url,
    uri: uri,
    size: size,
    localId: localId,
    type: type,
    path: path,
    bytes: bytes,
  );
}

class UploadFileRequestEntity {
  final PlatformFile file;
  UploadFileRequestEntity({required this.file});

  UploadFileRequestDto toDto() => UploadFileRequestDto(file: file);
}

enum UploadFileType { file, image }

class EditingAttachment extends Equatable {
  final String filename;
  final String extension;
  final String url;
  final UploadFileType type;
  final String rawString;

  EditingAttachment({
    required this.filename,
    required this.extension,
    required this.url,
    required this.type,
    required this.rawString,
  });

  @override
  List<Object?> get props => [filename, extension, url, type, rawString];
}

sealed class UploadFileEntity {
  final String localId;
  final String filename;
  final int size;
  final UploadFileType type;
  final String? path;
  final Uint8List bytes;

  const UploadFileEntity({
    required this.localId,
    required this.filename,
    required this.size,
    required this.type,
    this.path,
    required this.bytes,
  });
}

class UploadedFileEntity extends UploadFileEntity {
  final String url;
  final String? uri;

  const UploadedFileEntity({
    required super.localId,
    required super.filename,
    required super.type,
    required super.size,
    super.path,
    required super.bytes,
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
    required super.type,
    required super.path,
    required super.bytes,
    this.bytesSent,
    this.bytesTotal,
  });

  double? get progress =>
      (bytesSent != null && bytesTotal != null && bytesTotal! > 0) ? (bytesSent! / bytesTotal!).clamp(0.0, 1.0) : null;

  UploadingFileEntity copyWith({
    String? localId,
    String? filename,
    UploadFileType? type,
    String? path,
    int? size,
    int? bytesSent,
    int? bytesTotal,
    Uint8List? bytes,
  }) {
    return UploadingFileEntity(
      localId: localId ?? this.localId,
      filename: filename ?? this.filename,
      size: size ?? this.size,
      type: type ?? this.type,
      bytesSent: bytesSent ?? this.bytesSent,
      bytesTotal: bytesTotal ?? this.bytesTotal,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
    );
  }
}
