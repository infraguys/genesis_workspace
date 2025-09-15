import 'dart:io';
import 'dart:typed_data';

import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';

import 'platform_chunk_reader_stub.dart';

export 'platform_chunk_reader_stub.dart'; // 👈 реэкспорт интерфейса

class _IoChunkReader implements PlatformChunkReader {
  final String path;
  RandomAccessFile? _raf;
  _IoChunkReader(this.path);

  @override
  Future<void> open() async {
    _raf = await File(path).open();
  }

  @override
  Future<int> length() async => File(path).length();

  @override
  Future<Uint8List> read(int offset, int count) async {
    final RandomAccessFile raf = _raf!;
    raf.setPositionSync(offset);
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
  final String? path = body.file.path;
  if (path == null || path.isEmpty) {
    throw StateError('IO reader requires a valid file path');
  }
  return _IoChunkReader(path);
}
