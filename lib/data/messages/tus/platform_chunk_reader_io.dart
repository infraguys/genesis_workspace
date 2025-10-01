import 'dart:io';
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
    if (offset < 0 || offset >= data.length || offset >= end) {
      return Uint8List(0);
    }
    // sublistView не копирует данные
    return Uint8List.sublistView(data, offset, end);
  }

  @override
  Future<void> close() async {}
}

class _IoChunkReader implements PlatformChunkReader {
  final String path;
  RandomAccessFile? _raf;
  _IoChunkReader(this.path);

  @override
  Future<void> open() async {
    _raf = await File(path).open();
  }

  @override
  Future<int> length() async {
    final RandomAccessFile raf = _raf ??= await File(path).open();
    return await raf.length();
  }

  @override
  Future<Uint8List> read(int offset, int count) async {
    final RandomAccessFile raf = _raf!;
    await raf.setPosition(offset);
    final List<int> bytes = await raf.read(count);
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> close() async {
    await _raf?.close();
    _raf = null;
  }
}

PlatformChunkReader createPlatformChunkReader(UploadFileRequestDto body) {
  final Uint8List? bytes = body.file.bytes;
  if (bytes != null && bytes.isNotEmpty) {
    return _MemoryChunkReader(bytes);
  }

  final String? filePath = body.file.path;
  if (filePath != null && filePath.isNotEmpty) {
    return _IoChunkReader(filePath);
  }

  throw StateError('PlatformChunkReader: neither bytes nor path provided');
}
