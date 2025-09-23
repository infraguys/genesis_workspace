import 'dart:typed_data';

import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';

import 'platform_chunk_reader_stub.dart';

class _MemoryChunkReader implements PlatformChunkReader {
  final Uint8List data;
  _MemoryChunkReader(this.data);
  @override
  Future<void> open() async {}
  @override
  Future<int> length() async => data.length;
  @override
  Future<Uint8List> read(int offset, int count) async {
    final int end = (offset + count) > data.length ? data.length : (offset + count);
    if (offset < 0 || offset >= data.length || offset >= end) return Uint8List(0);
    return Uint8List.sublistView(data, offset, end);
  }

  @override
  Future<void> close() async {}
}

PlatformChunkReader createPlatformChunkReader(UploadFileRequestDto body) {
  final Uint8List? bytes = body.file.bytes;
  if (bytes != null && bytes.isNotEmpty) {
    return _MemoryChunkReader(bytes);
  }
  throw StateError('Web: bytes are required for upload (no file path available).');
}
