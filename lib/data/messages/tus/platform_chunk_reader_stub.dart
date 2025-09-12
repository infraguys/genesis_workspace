import 'dart:typed_data';

import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';

abstract class PlatformChunkReader {
  Future<void> open();
  Future<int> length();
  Future<Uint8List> read(int offset, int count);
  Future<void> close();
}

PlatformChunkReader createPlatformChunkReader(UploadFileRequestDto body) =>
    throw UnimplementedError('No platform reader implementation found');
