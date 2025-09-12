import 'dart:typed_data';

import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';

import 'platform_chunk_reader_stub.dart';

export 'platform_chunk_reader_stub.dart';

class _WebChunkReader implements PlatformChunkReader {
  final Uint8List bytes;
  _WebChunkReader(this.bytes);

  @override
  Future<void> open() async {}

  @override
  Future<int> length() async => bytes.length;

  @override
  Future<Uint8List> read(int offset, int count) async {
    final int end = (offset + count).clamp(0, bytes.length);
    return Uint8List.sublistView(bytes, offset, end);
  }

  @override
  Future<void> close() async {}
}

PlatformChunkReader createPlatformChunkReader(UploadFileRequestDto body) {
  final Uint8List? data = body.file.bytes;
  if (data == null || data.isEmpty) {
    throw StateError('Web reader requires non-empty bytes');
  }
  return _WebChunkReader(data);
}
