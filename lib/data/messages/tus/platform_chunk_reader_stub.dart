import 'dart:typed_data';

abstract class PlatformChunkReader {
  Future<void> open();
  Future<int> length();
  Future<Uint8List> read(int offset, int count);
  Future<void> close();
}
