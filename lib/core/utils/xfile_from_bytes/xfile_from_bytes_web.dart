import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:web/web.dart' as web;

Future<XFile> xFileFromBytes(Uint8List bytes, {required String filename, String? mimeType}) async {
  final String mt = mimeType ?? 'application/octet-stream';
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mt));
  final url = web.URL.createObjectURL(blob);
  return XFile(url, name: filename, mimeType: mt);
}
