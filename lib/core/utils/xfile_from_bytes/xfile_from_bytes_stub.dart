import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

Future<XFile> xFileFromBytes(Uint8List bytes, {required String filename, String? mimeType}) async {
  return XFile.fromData(bytes, name: filename, mimeType: mimeType);
}
