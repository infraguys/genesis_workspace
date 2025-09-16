import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

external Future<XFile> xFileFromBytes(
  Uint8List bytes, {
  required String filename,
  String? mimeType,
});
